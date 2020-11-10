
class Dashboard::Api::V1::ApiMasterController < Api::V1::ApiMasterController
  require 'date'

  def get_followings_demographics(business)    
    males = []
    females = []
    gays = []

    age_range_18_25 = []
    age_range_26_34 = []
    age_range_35_46 = []
    age_range_47_plus = []

    demographics = {}
    gender_based_demographics = {}
    age_based_demographics = {}
 
    total_count = business.followers.size
   
    business.followers.each do |follower| 
     case follower.gender
       when 'male'
         males.push(follower)
       when 'female'
         females.push(follower)
       when 'gay'
         gays.push(follower)
       else
          'No users'
        end
        
        age = get_age(follower.dob)

        case age

        when 18...25
          age_range_18_25.push(age)
        when 26...34
          age_range_26_34.push(age)
        when 35...46
          age_range_35_46.push(age)
        when age > 47
          age_range_47_plus(age)
        else
          'not age'
        end
     end #each
     
     gender_based_demographics['males'] = if males.size > 0 then males.uniq.size.to_f / total_count.to_f * 100.0 else 0 end

      gender_based_demographics['females'] = if females.size > 0 then females.uniq.size.to_f / total_count.to_f * 100.0  else 0 end

      gender_based_demographics['gays'] = if gays.size > 0 then gays.uniq.size.to_f / total_count.to_f * 100.0  else 0 end
      
      age_based_demographics['18-25'] = if age_range_18_25.size > 0 then age_range_18_25.size.to_f / total_count.to_f * 100.0 else 0 end 

      age_based_demographics['26-34'] = if age_range_26_34.size > 0 then age_range_26_34.size.to_f / total_count.to_f * 100.0 else 0 end 

      age_based_demographics['35-46'] = if age_range_35_46.size > 0 then age_range_18_25.size.to_f / total_count.to_f * 100.0 else 0 end 

      age_based_demographics['47-plus'] = if age_range_47_plus.size > 0 then age_range_18_25.size.to_f / total_count.to_f * 100.0 else 0 end 

      demographics["gender_based"] = gender_based_demographics
      demographics["age_based"] = age_based_demographics

      demographics
 end


 def get_age(dob) 
    dob = DateTime.parse(dob)
    now = Time.now.utc.to_date
    now.year - dob.year - ((now.month > dob.month || (now.month == dob.month && now.day >= dob.day)) ? 0 : 1)
 end


 def get_dashboard_event_object(event)
  e = {
    "id" => event.id,
    "image" => event.image,
    "status"  => event.status
  }
 end


end

