module Version
  def self.current_version
    env = Rails.env[0].to_s.upcase rescue ''
    branch = `git status | sed -n 1p`.split(" ").last[0].to_s.upcase rescue ''
    date_string = "051916"
    "11.28.R03-#{env}#{date_string}"
  end
end