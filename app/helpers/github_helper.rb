module GithubHelper
  
  def exercism_contributors
    github = Github.new do |config|
      config.client_id = ENV["GH_BASIC_CLIENT_ID"]
      config.client_secret = ENV["GH_BASIC_SECRET_ID"]
      config.stack do |builder|
        builder.use Faraday::HttpCache, store: Rails.cache
        builder.adapter Faraday.default_adapter
      end
    end
    exercism_repos = github.repos.list(user: "exercism").to_a 
    exercism_repos.delete_if {|x| x[:size] == 0}
    exercism_repos.map do |r|
      github.repos.list_contributors('exercism',r.name).map do |c|
        c
      end
    end
  end
  
  def render_contributors
    ec = exercism_contributors
    render :partial => '/layouts/github_contributors', :locals => {:repos  => ec}
  end 

end
