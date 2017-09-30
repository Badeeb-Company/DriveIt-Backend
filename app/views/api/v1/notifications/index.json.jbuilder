json.notifications @notifications do |notification|
	json.id notification.id
	json.title notification.title
	json.description notification.description
	json.created_at notification.created_at.strftime('%d-%m-%Y')
end