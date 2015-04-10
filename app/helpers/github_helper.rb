module GithubHelper
  
  def exercism_contributors
    Rails.cache.fetch(:contributors, expires_in: 1.hour) do
      github = Github.new do |config|
        config.client_id = ENV["GH_BASIC_CLIENT_ID"]
        config.client_secret = ENV["GH_BASIC_SECRET_ID"]
      end
      exercism_repos = github.repos.list(user: "exercism").to_a 
      exercism_repos.delete_if {|x| x[:size] == 0}
      exercism_repos.each do |r|
        github.repos.list_contributors('exercism',r.name).map do |c|
          Hash["repo",r,"contributor",c]
        end 
      end
    end
  end
  
  def exercism_something(hmm)
   contributors = exercism_contributors
   contributors.flatten.select {|x| x["contributor"].login == hmm}
  end

  def exercism_repos
    Rails.cache.fetch(:repos, expires_in: 1.hour) do
      github = Github.new do |config|
        config.client_id = ENV["GH_BASIC_CLIENT_ID"]
        config.client_secret = ENV["GH_BASIC_SECRET_ID"]
      end
      github.repos.list(user: "exercism").to_a 
    end
  end

  def render_contributors
    ec = exercism_contributors
    render :partial => '/layouts/github_contributors', :locals => {:repos  => ec}
  end 

end
