namespace :authorule do

  desc "Lists all available permissions"
  task :list => :environment do
    Authorule.available_permissions.each do |kind, permissions|
      puts "#{kind}:"
      permissions.each do |permission|
        if permission.available_actions.blank?
          puts "  #{permission.name}"
        else
          puts "  #{permission.name} (#{permission.available_actions.join(', ')})"
        end
      end
    end
  end

end