namespace :tally do
  desc "Sweep all outdated keys from the data store"
  task sweep: :environment do
    Tally::SweeperJob.perform_now

    Rake::Task["tally:wait_for_async_queue"].execute
  end

  desc "Archive today's temporary keys into record entries in the database"
  task archive: :environment do
    Tally::ArchiverJob.perform_now

    Rake::Task["tally:wait_for_async_queue"].execute
  end

  desc "Archive yesterday's temporary keys into record entries in the database"
  task "archive:yesterday": :environment do
    Tally::ArchiverJob.perform_now("yesterday")

    Rake::Task["tally:wait_for_async_queue"].execute
  end

  # For async ActiveJob queue, wait until jobs have processed, then exit
  #
  # This is not needed for other adapters besides async, but since it is the
  # Rails default, we're accounting for it here.
  task wait_for_async_queue: :environment do
    if Rails.application.config.active_job.queue_adapter == :async
      ActiveJob::Base.queue_adapter.shutdown(wait: true)
    end
  end


end
