module GithubHelper
  
  def exercism_contributors
    Rails.cache.fetch(:contributors, expires_in: 1.hour) do
      github = Github.new do |config|
        config.client_id = ENV["GH_BASIC_CLIENT_ID"]
        config.client_secret = ENV["GH_BASIC_SECRET_ID"]
      end
      exercism_repos = github.repos.list(user: "exercism").to_a 
      exercism_repos.delete_if {|x| x[:size] == 0}
      exercism_repos.map do |r|
        github.repos.list_contributors('exercism',r.name).map do |c|
          Hash["repo",r,"contributor",c]
        end 
      end
    end
  end
  
  def contributors_by_name
    exercism_contributors.flatten.map{|contributor| contributor["contributor"]}.uniq{|x| x[:login]}
  end

  def contributor_instances(name)
    exercism_contributors.flatten.select{|x| x["contributor"].login == name}
  end

  def first_contributor_instance(name)
    contributor_instances(name).first["contributor"] 
  end

  
  def render_contributors
    ec = contributors_by_name 
    render :partial => '/layouts/github_contributors', :locals => {:contributors_list => ec}
  end 

end
