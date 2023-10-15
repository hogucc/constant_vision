# frozen_string_literal: true

require_relative 'constant_vision/version'

module ConstantVision
  def self.find_origin_of_constant(constant_name, context)
    Rails.application.eager_load! if defined?(Rails)

    context_namespaces = context.to_s.split('::')
    target_constant_names = constant_name.to_s.split('::')

    # constant_nameが絶対パスで指定されている場合
    if constant_name.start_with?('::')
      absolute_module = constant_from_string(constant_name)
      return absolute_module ? constant_name : "#{constant_name} not found in #{context}"
    end

    # contextからトップレベルまでの全ての名前空間を探索
    (context_namespaces.length + 1).downto(0) do |i|
      current_context = context_namespaces.first(i).join('::')
      current_module = constant_from_string(current_context)
      next if current_module.nil?

      # target_constant_namesを探索
      target_module = target_constant_names.inject(current_module) do |mod, const_name|
        break nil unless mod.const_defined?(const_name, false)
        break mod.const_get(const_name, false)
      end

      # target_moduleが見つかればその名前を返す
      if target_module
        return (current_context.empty? ? "" : "#{current_context}::") + target_constant_names.join('::')
      end
    end

    # トップレベルから定数を検索
    top_level_module = constant_from_string(constant_name)
    return constant_name if top_level_module

    # contextがクラスである場合、そのスーパークラスを探索
    if context.is_a?(Class) && context.superclass
      superclass_name = find_origin_of_constant(constant_name, context.superclass)
      return "#{context}::#{constant_name}" unless superclass_name.include?("not found")
    end

    # 定数が見つからない場合、エラーメッセージを返す
    "#{constant_name} not found in #{context}"
  end

  def self.constant_from_string(str)
    str.split('::').reject(&:empty?).inject(Object) do |mod, class_name|
      return nil unless mod.const_defined?(class_name, false)
      mod.const_get(class_name, false)
    end
  end

  def self.find_constant(constant_name)
    Rails.application.eager_load! if defined?(Rails)

    matching_modules = []

    ObjectSpace.each_object(Module) do |mod|
      # Objectの直接の子定数を処理
      if mod == Object && Object.const_defined?(constant_name, false)
        matching_modules << Object.const_get(constant_name).to_s
        next
      end

      next if mod == Object # Objectのそれ以外の定数は処理から除外

      # falseを指定することで、継承チェーンを検索しない
      if mod.const_defined?(constant_name, false)
        # モジュールの名前を取得し、定数名と連結
        full_name = "#{mod.name}::#{constant_name}"
        matching_modules << full_name
      end
    end

    matching_modules
  end
end
