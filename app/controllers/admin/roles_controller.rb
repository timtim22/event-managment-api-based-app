class Admin::RolesController < Admin::AdminMasterController
    def index
     @roles = Role.all
    end
end
