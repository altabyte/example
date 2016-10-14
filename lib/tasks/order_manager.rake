namespace :order_manager do
  desc "Clean DB"
  task :cleandb => :environment do
    puts "Recreate and seed DB"
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:schema:load'].invoke
    Rake::Task['db:seed'].invoke
    Rake::Task['order_manager:import_xml'].invoke
  end

  desc "Import Text / Dev XML Files"
  task :import_xml => :environment do
    root_import_dir = "#{Rails.root}/import/XML"

    puts "Configuration Import"
    data = File.read("#{root_import_dir}/base_setup.xml")
    ImportConfiguration.process_import_file(data)
    puts "Configuration Imported"

  end

  desc "Import Text / Dev XML Files"
  task :import_excel_clothing_xml => :environment do
    root_import_dir = "#{Rails.root}/import/XML"

    puts "Configuration Import"
    data = File.read("#{root_import_dir}/excel_clothing.xml")
    ImportConfiguration.process_import_file(data)
    puts "Configuration Imported"
  end

  desc "Import HS Codes"
  task :import_hs_codes => :environment do
    require 'roo'
    file = "#{Rails.root}/import/XLS/HSCodes.xls"
    count = 0

    spreadsheet = Roo::Excel.new(file, nil, :ignore)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      if row['Commodity Code'].present? and row['Description'].present?

        code = row['Commodity Code'].gsub('.', '')
        hscode = HsCode.find_or_create_by_code(code)
        hscode.description = row['Description'].squish
        hscode.save!
        count += 1
      end
    end
    puts "created #{count} HS Records"
    #https://www.uktradeinfo.com/tradetools/icn/pages/icninfoandhelp.aspx
  end

  desc "Update system settings"
  task :update_system_settings => :environment do
    puts "Updating System Settings"
    SystemSetting.update_settings
    puts "Updated System Settings"
  end


  desc "Post Deployment Tasks"
  task :post_deploy_tasks => :environment do
    puts "Removing reports where physical file is missing"
    count = 0
    Report.all.each do |report|
      unless File.file?(report.report_file.current_path)
        count += 1
        puts "Deleting report #{report.id}"
        report.delete
      end
    end
    puts "Removed #{count} reports that where missing the physical file"

    puts "Resetting Packaging Types"
    PackagingType.reset_defaults
    puts "Packaging Types Reset"

  end

  # It requires ACK - http://betterthangrep.com/
  task :find_unused_images do
    images = Dir.glob('app/assets/images/**/*')

    images_to_delete = []
    images.each do |image|
      unless File.directory?(image)
        # print "\nChecking #{image}..."
        print "."
        result = `ack -g -i '(app|public)' | ack -x -w #{File.basename(image)}`
        if result.empty?
          images_to_delete << image
        else
        end
      end
    end
    puts "\n\nDelete unused files running the command below:"
    puts "rm #{images_to_delete.join(" ")}"
  end

end
