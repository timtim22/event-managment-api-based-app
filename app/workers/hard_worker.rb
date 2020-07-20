class HardWorker
  include Sidekiq::Worker

  def perform(*args)
    # Do something
    p 'Hello World!'
  end
end
