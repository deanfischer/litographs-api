###
# Helper methods and utilities for seed data.
###

require 'yaml'

# Helper method to load seed data from YAML, and map each record
def seed(name, &block)
  seed_records = YAML.load_file(File.join(SEED_DATA_BASEPATH, "#{name}.yml"))
  if seed_records.kind_of? Hash
    seed_records.symbolize_keys! # symbolize keys
  end
  seed_records.map do |record|
    block.call(record.symbolize_keys!)
  end
end