class PackagingType < ActiveRecord::Base
  attr_accessible :custom, :fedex, :name, :ad_hoc

  def self.reset_defaults
    PackagingType.find_or_create_by_name('CUSTOM', :custom => true)
    PackagingType.find_or_create_by_name('AD_HOC', :ad_hoc => true)

    Fedex::Request::Base::PACKAGING_TYPES.each do |package|
      if package != 'YOUR_PACKAGING'
        PackagingType.find_or_create_by_name(package, :fedex => true)
      end
    end
  end
end
