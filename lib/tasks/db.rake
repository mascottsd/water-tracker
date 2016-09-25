namespace :db do

  desc 'Rebuilds the database and seeds it'
  task :rebuild do
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    Rake::Task["db:seed"].invoke
    Rake::Task["db:demo"].invoke if ENV["DEPLOY_DEMO"] == "true"
  end

  desc 'Runs all seed files under seed folder'
  task seed: :environment do
    Track::Util::Data::Seeder.run!
  end

  desc 'Runs all demo files under demo folder'
  task demo: :environment do
    Track::Util::Data::Seeder.run!(include_demo: true)
  end

  #----------------------------------------------------------------
	def connect_source
		ActiveRecord::Base.establish_connection(
			:adapter  => "mysql2",
			:host     => "127.0.0.1",
			:port 		=> 52266,
			:username => "aptible",
			:password => "ZUa3arpTUCj-YG20ztcj96jt-cWGYV8V",
			:database => "db"
			)
	end
	def connect_target
		ActiveRecord::Base.establish_connection(
			:adapter  => "mysql2",
			:host     => "127.0.0.1",
			:username => "root",
			:password => "",
			:database => "thrive_development"
			)
	end
  #----------------------------------------------------------------
	desc "Simple test to see the number of Users in source vs target dbs"
	task :count_users => :environment do
		model = 'users'.classify.constantize
		test_count(model)
	end

	desc "Print all db tables"
	task :print_tables do
		connect_source
		ActiveRecord::Base.connection.tables.each do |t|
			puts t
			# ActiveRecord::Base.connection.columns(t).each { |c| puts "- #{c.name}: #{c.type} #{c.limit}" }
		end
	end
	desc "Print all db tables"
	task :print_tables do
		connect_source
		ActiveRecord::Base.connection.tables.each do |t|
			puts t
			# ActiveRecord::Base.connection.columns(t).each { |c| puts "- #{c.name}: #{c.type} #{c.limit}" }
		end
	end


	desc "Migrate db from one environment to another"
	task :migrate_copy => :environment do
		ActiveRecord::Base.logger = nil  # silence the logger chatter
		puts "------- start migrate --------"
		connect_source
		# admins,filters,logins, questions,seeds,strategies,,survey_options,tenants, users, **user_action_steps**384/1018, **user_filter**
		# schema_migrations, sessions, surverys - NameError: uninitialized constant SchemaMigration
		# survey_answers - ActiveRecord::StatementInvalid: Mysql2::Error: Field 'survey_id' doesn't have a default value: INSERT INTO `survey_answers` (`survey_answer_id`, `question_id`, `sequence`, `type_of`, `section`, `created_at`, `updated_at`) VALUES ('EC0872E2654511E6B7D90242AC1122BA', 'EA9B0776654511E6B7D90242AC1122BA', 0, 'boolean', 'profile', '2016-08-18 13:16:06', '2016-08-18 13:16:06')
		#			- created by User ??
		# Skipped Tables - logins, seeds, schema_migrations, sessions
		# KEEP TABLES THAT HAVE FOREIGN KEYS LAST
		tables = ['action_steps', 'admins', 'users', 'filters', 'notifications', 'questions', 'strategies', 'survey_options', 'tenants',
							'survey_answers', 'user_filters', 'user_action_steps', 'action_step_filters', 'question_filters']
		# tables = ['question_filters']  # ActiveRecord::Base.connection.tables #['surveys'] #

		tables.each do |t|
			connect_source
			model = t.classify.constantize
			rows = model.all
			puts "==== Copying Table '#{t}' with #{rows.count} rows..."
			data = rows.map { |r| r.attributes }

			connect_target
			model.delete_all
			cnt = 0
			data.each do |r|
				if (t == 'notifications')
					r['body'] = r['body'].truncate 32 * 1024
				end
				if (t == 'action_steps')
					r['day_1'] = r['day_1'].truncate 32 * 1024 if r['day_1']
					r['day_2'] = r['day_2'].truncate 32 * 1024 if r['day_2']
					r['day_3'] = r['day_3'].truncate 32 * 1024 if r['day_3']
					r['day_4'] = r['day_4'].truncate 32 * 1024 if r['day_4']
					r['day_5'] = r['day_5'].truncate 32 * 1024 if r['day_5']
				end
				if (t == 'users')
					# desc "Redact (blot out) sensitive information"
					# https://github.com/stympy/faker#installing
					r['password'] = 'Ilike2thrive!'  # "1!Biking"
					r['first_name'] = Faker::Name.first_name;
					r['last_name'] = Faker::Name.last_name;
					r['mobile_number'] = Faker::PhoneNumber.phone_number.truncate 20;
					r['home_number'] = Faker::PhoneNumber.phone_number.truncate 20;
					r['email'] = Faker::Internet.email;
					# r['time_zone'] = 'Mountain Time (US & Canada)';
					r['access_token'] = 'missionhope' if r['subdomain'] == 'missionhope'
				end

				x = model.new r  # model.create r
				x.survey_id = r['survey_id']if (t == 'survey_answers')  # necessary hack - otherwise, "Mysql2::Error: Field 'survey_id' doesn't have a default value"
  			# if !t.end_with?('_filters') || !x.filter.blank?
	  			puts "\tERROR #{t}, id = #{x.id}: #{x.errors.messages}" unless x.save
		  	# end
		  	puts "\tdone #{cnt} / #{data.count}" unless cnt > 0 && cnt.divmod(400) == 0
			end

			test_count(model)
		end

		puts "------- fin migrate --------"
	end

	desc "Drop all data from Target"
	task :drop do
		# Check that this is not production
		connect_target
		# model.delete_all
	end

	desc "Verify migration results"
	task :verify do
	end

	# task :run => [:drop, :read, :redact, :copy, :verify]

	def test_count(model)
		connect_source
		puts "\tSource #{model.to_s} has #{model.count} rows"

		connect_target
		puts "\tTarget #{model.to_s} has #{model.count} rows"
	end
end
