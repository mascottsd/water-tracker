require 'fileutils'
require 'thrive/util/data/seed_proxy'

module Track::Util::Data::Seeder

  # this is the primary entry point into the Seeder responsible for running all of the seed files in each of the
  # registered GEMs and the host rails application. Unlike the migrator, it is not require to move each file into
  def self.run!(options={})


    # locate the paths for all seed files
    paths = Array(process_paths(options[:include_demo]))

    # fetch the full path names for each file
    files = Dir[*paths.map { |p| "#{p}/**/[0-9]*_*.rb" }]

    # load all of the current seeds and reference in an array
    loaded_seeds = Seed.select(:version).map {|r| r.version}

    seeds = files.map do |file|
      version, name, scope = file.scan(/([0-9]+)_([_a-z0-9]*)\.?([_a-z0-9]*)?.rb/).first
      name, version = name.camelize, version.to_i
      Track::Util::Data::SeedProxy.new(name, version, file)
    end

    # reorder the seeds to ensure they run in the correct order across all gems
    seeds = seeds.sort_by(&:version)

    puts "=> Seeding data"
    # process each seed determining first if they are eligible to be run.
    seeds.each do |seed|

      unless loaded_seeds.include?(seed[:version].to_s)
        start = Time.now
        puts "-- #{seed[:name]} (#{seed[:version]})"
        begin
          load seed[:filename]
          Seed.create(:version => seed[:version].to_s)
        rescue Exception => e
          puts e.message
        end
        diff = Time.now - start
        puts "   -> #{diff}s"
      end
    end

  end # def self.run

  # Determine the paths containing the seed files. Indicate if the
  # paths should include the demo files.
  def self.process_paths(include_demo=false)

    result = [File.join(Rails.root.to_s, "db", "seed")]
    result += [File.join(Rails.root.to_s, "db", "demo")] if include_demo

    result
  end # def self.process_paths

end # module Track::Util::Data::Seeder