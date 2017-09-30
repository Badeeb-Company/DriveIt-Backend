json.meta do
	json.status response.status
	if !@message
		json.message 'Success'
	else
		json.message @message
	end
end
json.data JSON.parse(yield)