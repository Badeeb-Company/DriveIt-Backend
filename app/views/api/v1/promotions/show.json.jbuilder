json.promotion_info do
	json.extract! @promotion, :id, :title, :description
	json.due_date @promotion.due_date
	json.photos @promotion.photos do |photo|
		json.id photo.id
		json.url photo.photo.thumbnail.url
	end
end