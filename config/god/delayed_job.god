APPLICATION_ROOT = "/var/www/production/ordermanager"
RAILS_ENV = "production"

delayed_queues = [
    [1, 'customer'],
    [2, 'channel'],
    [3, 'channel'],
    [4, 'delivery'],
    [5, 'dmo'],
]


delayed_queues.each do |queue|
  God.watch do |w|
    w.name = "dj_#{queue[1]}_#{queue[0]}"
    w.interval = 15.seconds
    w.start = "/bin/bash -c 'cd #{APPLICATION_ROOT}/current; /usr/bin/env RAILS_ENV=#{RAILS_ENV} #{APPLICATION_ROOT}/current/script/delayed_job start -i #{queue[0]} --queue=#{queue[1]} > /home/deploy/god/dj_#{queue[1]}.log'"
    w.stop = "/bin/bash -c 'cd #{APPLICATION_ROOT}/current; /usr/bin/env RAILS_ENV=#{RAILS_ENV} #{APPLICATION_ROOT}/current/script/delayed_job stop -i #{queue[0]}'"
    w.log = "#{APPLICATION_ROOT}/shared/log/god_dj.log"
    w.start_grace = 5.minutes
    w.restart_grace = 5.minutes
    w.stop_grace = 5.minutes
    w.pid_file = "#{APPLICATION_ROOT}/shared/pids/delayed_job.#{queue[0]}.pid"
    w.uid = 'deploy'
    w.gid = 'deploy'

    w.behavior(:clean_pid_file)

    w.start_if do |start|
      start.condition(:process_running) do |c|
        c.interval = 5.seconds
        c.running = false
        c.notify = 'stuart'
      end
    end

    w.restart_if do |restart|
      restart.condition(:memory_usage) do |c|
        c.above = 300.megabytes
        c.times = [3, 5] # 3 out of 5 intervals
        c.notify = 'stuart'
      end

      restart.condition(:cpu_usage) do |c|
        c.above = 50.percent
        c.times = 5
        c.notify = 'stuart'
      end
    end

    # lifecycle
    w.lifecycle do |on|
      on.condition(:flapping) do |c|
        c.to_state = [:start, :restart]
        c.times = 5
        c.within = 5.minute
        c.transition = :unmonitored
        c.retry_in = 10.minutes
        c.retry_times = 5
        c.retry_within = 2.hours
        c.notify = 'stuart'
      end
    end
  end
end


