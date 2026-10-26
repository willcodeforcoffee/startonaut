module Admin
  class FeatureFlagsController < BaseController
    # GET /admin/feature_flags
    def show
    end

    # PATCH /admin/feature_flags
    def update
      FeatureFlag.transaction do
        feature_flag_params.each do |name, value|
          FeatureFlag.set!(name, ActiveModel::Type::Boolean.new.cast(value))
        end
      end

      redirect_to admin_feature_flags_path, notice: "Feature flags updated."
    end

    private

    def feature_flag_params
      params.expect(feature_flags: FeatureFlag::DEFINITIONS.keys)
    end
  end
end
