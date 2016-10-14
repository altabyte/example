module FedexSettingsHelper

  def label_types
    ["PAPER_4X6",
     "PAPER_4X8",
     "PAPER_4X9",
     "PAPER_7X4.75",
     "PAPER_8.5X11_BOTTOM_HALF_LABEL",
     "PAPER_8.5X11_TOP_HALF_LABEL",
     "PAPER_LETTER"]
  end

  def fedex_service_type_collection
    services = []
    Fedex::Request::Base::SERVICE_TYPES.each do |service|
      name = service.to_s.downcase.titleize
      services << [name, service]
    end
    services
  end

  def fedex_package_type_collection
    packages = []
    packages << ['Ad-Hoc', 'CUSTOM']
    Fedex::Request::Base::PACKAGING_TYPES.each do |package|
      name = package.to_s.downcase.titleize
      packages << [name, package]
    end
    packages
  end
end
