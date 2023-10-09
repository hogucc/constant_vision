# frozen_string_literal: true

require_relative 'constant_vision/version'

module ConstantVision
  def self.find_origin_of_constant(constant_name, context)
    namespaces = context.to_s.split('::')
    base_constant = constant_name.to_s.split('::').first

    # 名前空間を逆順に走査して、該当する名前空間を検索
    matching_namespace = namespaces.reverse_each.find do |namespace|
      current_module = constant_from_string(namespaces[0..namespaces.index(namespace)].join('::'))
      # 名前空間に該当する定数が存在するか、名前空間と定数名が一致する
      current_module.const_defined?(base_constant, false) || namespace == base_constant
    end

    # 該当する名前空間が見つかった場合
    return constant_from_string(namespaces[0..namespaces.index(matching_namespace)].join('::')) if matching_namespace

    # トップレベルでの検索
    return Object if Object.const_defined?(base_constant, false)

    nil
  end

  def self.constant_from_string(str)
    str.split('::').inject(Object) { |mod, class_name| mod.const_get(class_name) }
  end

  def self.find_constant(constant_name)
    Rails.application.eager_load! if defined?(Rails)

    matching_modules = []

    ObjectSpace.each_object(Module) do |mod|
      # Objectの直接の子定数を処理
      if mod == Object && Object.const_defined?(constant_name, false)
        matching_modules << Object.const_get(constant_name)
        next
      end

      next if mod == Object # Objectのそれ以外の定数は処理から除外

      matching_modules << mod.const_get(constant_name) if mod.const_defined?(constant_name, false) # falseを指定することで、継承チェーンを検索しない
    end

    matching_modules
  end
end
