module GithubHelper
  
  def exercism_contributors
    Rails.cache.fetch(:contributors, expires_in: 1.hour) do
      github = Github.new do |config|
        config.client_id = ENV["GH_BASIC_CLIENT_ID"]
        config.client_secret = ENV["GH_BASIC_SECRET_ID"]
      end
      exercism_repos = github.repos.list(user: "exercism").to_a.delete_if {|x| x[:size] == 0}
      exercism_repos.map do |r|
        1.upto(Float::INFINITY).with_object([]) do |pagenum, contributors|
          page = github.repos.list_contributors('exercism', r.name, page: pagenum)
          page.each { |c| contributors << Hash["repo", r, "contributor", c] }
          link = page.response.headers['link']
          last_pagenum = if link
            last_link = link.split(',').grep(/rel="last"/).first
            last_link ||= "page=#{pagenum}"
            last_link[/page=(\d+)/, 1].to_i
          else
            pagenum
          end
          break contributors if pagenum == last_pagenum
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
