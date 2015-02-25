require 'grape'

class User
  include DataMapper::Resource
  include Litographs::UserDate

  attr_accessor :address_to_set, :genres_to_set

  ###
  # Properties
  ###

  property :id, Serial
  property :first_name, String, length: 0..40
  property :last_name, String, length: 0..40
  property :gender, Enum[:male, :female, :other, :unspecified], default: :unspecified
  property :email, String, unique: true, length: 4..64, format: :email_address, :messages => {
      :presence  => "Please enter your email address.",
      :is_unique => "An account already exists with this email.",
      :format    => "Please provide a valid email address."
    }
  property :created_at, DateTime, default: ->(r,p){ DateTime.now }
  property :last_login, DateTime, default: ->(r,p){ DateTime.now }
  property :login_count, Integer, default: 0
  property :auth_provider, String, lazy: [:auth]
  property :auth_uid, String, lazy: [:auth]
  property :auth_role, String
  property :password_hash, String # Legacy authentication

  has_user_date :dob, :context => :past

  has n, :addresses, constraint: :destroy
  has n, :user_genres, constraint: :destroy

  # #
  # Grape Entity (exposed in API)
  # #

  class Entity < Grape::Entity
    expose :id, documentation: { type: "Integer", desc: "The unique ID for this user" }
    expose :first_name, documentation: { type: "String", desc: "First name." }
    expose :last_name, documentation: { type: "String", desc: "Last name." }
    expose :gender, documentation: { type: "String", desc: "Gender." }
    expose :email, documentation: { type: "String", desc: "Email address." }
    expose :dob, documentation: { type: "String", desc: "Date of birth, accepts human readable formats." }
    expose :created_at, documentation: { type: "Date", desc: "Date this user was created." }
    expose :last_login, documentation: { type: "Date", desc: "Date this user last logged in." }
    expose :addresses, using: Address::Entity, documentation: { type: "Array", desc: "Array of addresses" }
    expose :genres, documentation: { type: "Object", desc: "Hash of genre preferences formatted as follows: {genre_slug: boolean}." }
  end

  def entity
    Entity.new(self)
  end


  ###
  # Validations
  ###

  validates_presence_of :email, :as => :email_address
  validates_presence_of :auth_provider, :when => [:using_third_party_auth]
  validates_presence_of :auth_uid, :when => [:using_third_party_auth]
  validates_presence_of :auth_role, :when => [:using_third_party_auth]
  validates_presence_of :password_hash, :when => [:using_local_auth]

  
  # #
  # Lifecycle
  # #

  after :save do
    # set_address
    set_genres
  end

  ###
  # Current user_id reference for models
  # this breaks MVC pretty badly so use sparingly!
  ###

  def self.current_user_id
    Thread.current[:current_user]
  end

  def self.current_user_id=(id)
    Thread.current[:current_user] = id
  end

  # Validate a supplied plain-text password against the user's password hash.
  # @return [Password] Bcrypt password instance.
  def password
    @password ||= Password.new(self.password_hash)
  end

  # Set the user's password, effectively setting the user's password hash.
  # @param [String] new password for user
  def password=(new_password)
    @password = Password.create(new_password)
    self.auth_provider = 'local'
    self.password_hash = @password
  end

  # Combine the user's first and last name to create a full name.
  def full_name
    return nil unless first_name
    unless last_name.nil?
      "#{first_name} #{last_name}"
    else
      "#{first_name}"
    end
  end

  def admin?
    self.auth_role == 'admin'
  end

  def staff?
    self.auth_role == 'staff' or admin?
  end

  # def address=(new_address)
  #   self.address_to_set = new_address
  # end

  # def set_address(address_obj=nil)
  #   if address_obj ||= address_to_set
  #     self.address_to_set = nil
  #     address = addresses.first || addresses.new
  #     address_obj.each do |k, v|
  #       address[k] = v
  #     end
  #     address.save
  #   end
  # end

  def primary_address
    # TODO add a primary address attr once multiple are supported
    addresses.first
  end

  def genres=(genres)
    self.genres_to_set = genres
  end

  def set_genres(genres_obj=nil)
    if genres_obj ||= genres_to_set
      self.genres_to_set = nil
      genres_obj.each do |slug, val|
        genre = Genre.first(slug: slug)
        bool = ![false, "false"].include?(val)
        if bool
          unless user_genres.first(genre: genre)
            user_genres.create(genre: genre)
          end
        else
          if u_genre = user_genres.first(genre: genre)
            u_genre.destroy
          end
        end
      end
    end
  end

  def genres
    genres = Hash[ Genre.all.map{|genre| [genre.slug, false]} ]
    user_genres.each do |user_genre|
      genres[user_genre.genre.slug] = true
    end
    genres
  end

  def self.find_with_oauth(oauth)
    user = first :auth_provider => oauth['provider'],
                 :auth_uid => oauth['uid']
  end

  def self.create_from_oauth(oauth)
    return false if User.find_with_oauth(oauth)
    user = new()
    user.set_oauth(oauth)
    user.state = 'editing_identity'
    user.save(:using_third_party_auth)
    user
  end

  # Given a user authentication oauth, set the user's primary method of 
  # authentication.
  #
  # @param auth [OmniAuth::Authoauth] the new oauth
  def set_oauth(auth)
    t = auth['provider'] == 'twitter'
    f = auth['provider'] == 'facebook'
    self.auth_provider = auth['provider']
    self.auth_uid = auth['uid']
    self.auth_role ||= 'user'
    if info = auth['info']
      if info['name']
        names = info['name'].split(' ')
        first_name = names.shift
        last_name = names.join(' ')
      end
      if info['first_name']
        first_last_name = info['first_name'] + (info['last_name'] or "")
      end
      # if image = info['image']
      #   self.remote_profile_photo_url ||= image.gsub('_normal', '') if t
      #   self.remote_profile_photo_url ||= image.gsub('square', 'large') if f
      # end
      self.first_name ||= info['first_name'] || first_name
      self.last_name ||= info['last_name'] || last_name
      self.email ||= info['email']
      # self.bio ||= info['description'] if t
      # self.username ||= info['nickname'] if t and User.username_available?(info['nickname'])[0]
      # self.username ||= first_last_name if f and User.username_available?(first_last_name)[0]
    end
  end

  # Find a user by id. This method is typically provided by ActiveRecord, but 
  # is omitted by DataMapper -- and inexplicably required by OmniAuth.
  def self.find_by_id(id)
    get(id) rescue nil
  end

  def forgot_auth!
    raise RuntimeError, "Cannot reset password unless auth_provider is local." unless local_auth_preferred?
    if local_auth_preferred?
      temp_password = ::Litographs::ContentHelpers.readable_password(10, 3)
      async_send_template_email('2-0-forgot-password', {temporary_password: temp_password})
      self.update(password: temp_password)
    end
  end
  
  def local_auth_preferred?
    auth_provider == 'local'
  end

  def oauth_preferred?
    !auth_provider.nil? and !local_auth_preferred?
  end

  def auth_method_chosen?
    oauth_preferred? or local_auth_preferred?
  end

  def has_valid_authentication?
    valid?(:using_third_party_auth) or valid?(:using_local_auth)
  end

  def async_send_template_email(*args)
    Resque.enqueue(::Litographs::UserSendEmailTemplateTask, self.id, *args)
  end

  def delayed_send_template_email(*args)
    Resque.enqueue_in(1.minute, ::Litographs::UserSendEmailTemplateTask, self.id, *args)
  end
  
  def delay_send_template_email_for(delay, *args)
    Resque.enqueue_in(delay, ::Litographs::UserSendEmailTemplateTask, self.id, *args)
  end

  def stop_send_template_email(*args)
    Resque.remove_delayed(::Litographs::UserSendEmailTemplateTask, self.id, *args)
  end

  def send_template_email(template_name, opt_merge_vars = {}, opts = {})
    begin
      template_content = opts.delete(:content).to_a.map!{|k, v| {name: k, content: v} }
      merge_vars = {
        username: self.username,
        first_name: self.first_name,
        last_name: self.last_name,
        email: self.email,
        created_at: self.created_at,
        invitation_token: self.invitation_token,
        website_url: self.website_url,
        profile_photo_url: self.profile_photo.sized_url(w:200, h:200, fit:'crop')
      }.merge!(opt_merge_vars)
      message = opts.merge({
        global_merge_vars: merge_vars.to_a.map!{|k, v| {name: k, content: v} },
        to: [{email: self.email, name: self.full_name}],
        google_analytics_domains: ["maptia.com", "blog.maptia.com"],
        google_analytics_campaign: "transactional"
      })
      Litographs.mailer.messages.send_template(template_name, template_content, message)
    rescue Mandrill::Error => e
      # Mandrill errors are thrown as exceptions
      puts "A mandrill error occurred: #{e.class} - #{e.message}"
      # A mandrill error occurred: Mandrill::UnknownSubaccountError - No subaccount exists with the id 'customer-123'    
      raise
    end
  end

end
