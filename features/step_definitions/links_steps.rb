Given(/^there are no #{capture_plural_factory}$/) do |plural_factory|
  name = plural_factory.singularize
  factory, name = *parse_model(name)
  model_class = pickle_config.factories[factory].klass
  model_class.delete_all
end

