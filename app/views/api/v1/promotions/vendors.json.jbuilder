json.vendors @vendors do |vendor|
	json.id vendor.id
	json.type vendor.vendor_type
	json.name vendor.name
	json.phone_number vendor.phone_number
	json.mobile_number vendor.mobile_number
	json.governorate vendor.governorate
	json.address vendor.address
	json.lat vendor.lat
	json.lng vendor.lng
end