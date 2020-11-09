module EventsHelper
def BoolToHuman(bool) 
	if(bool == true) 
		"Yes"	
		elsif(bool == false)
		 "No" 
	else
		"Wrong value"
	end
end

def BoolTocheckBox(bool)
  if(bool == true)
    "checked"
  elsif(bool == false)
    ""
  else
    "Wrong value"
  end
end

def BoolToNumber(bool)
  if(bool == true) 
		"1"	
		elsif(bool == false)
		 "0" 
	else
		"Wrong value"
	end
end
end
