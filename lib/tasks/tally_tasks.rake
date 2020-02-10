namespace :tally do
  desc "Sweep all outdated keys from the data store"
  task :sweep => :environment do
    Tally::Sweeper.sweep!
  end

  desc "Archive today's temporary keys into record entries in the database"
  task :archive => :environment do
    Tally::Archiver.archive!
  end

  desc "Archive yesterday's temporary keys into record entries in the database"
  task "archive:yesterday" => :environment do
    Tally::Archiver.archive! day: 1.day.ago
  end
end
