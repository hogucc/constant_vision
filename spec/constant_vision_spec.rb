# frozen_string_literal: true

RSpec.describe ConstantVision do
  describe '.find_constant' do
    context 'when multiple constants are defined' do
      before(:all) do
        module DummyModule
          MY_CONST = 'Test'
          ANOTHER_CONST = 'Another Test'
        end
      end

      after(:all) do
        Object.send(:remove_const, :DummyModule)
      end

      it 'finds MY_CONST' do
        result = ConstantVision.find_constant('MY_CONST')
        expect(result).to eq("DummyModule::MY_CONST")
      end

      it 'finds ANOTHER_CONST' do
        result = ConstantVision.find_constant('ANOTHER_CONST')
        expect(result).to eq("DummyModule::ANOTHER_CONST")
      end
    end

    context 'when no constants are defined' do
      it 'returns an empty array for OTHER_CONST' do
        result = ConstantVision.find_constant('OTHER_CONST')

        expect(result).to be_empty
      end
    end

    context 'when multiple constants are defined' do
      before(:all) do
        module Bar
          module Piyo
            module Hoge
            end
          end
        end

        module Foo
          module Bar
            class Baz
              def foo; end
            end
          end
        end
      end

      after(:all) do
        Object.send(:remove_const, :Foo)
        Object.send(:remove_const, :Bar)
      end

      it 'finds Bar' do
        result = ConstantVision.find_constant('Bar')
        expect(result).to eq("Bar,Foo::Bar")
      end

      it 'finds Bar::Baz' do
        result = ConstantVision.find_constant('Bar::Baz')
        expect(result).to eq("Foo::Bar::Baz")
      end
    end

    context 'when there are modules with overlapping namespaces' do
      before(:all) do
        module Zoo
          module Mammals
            module Cats
              class Lion
              end
            end
          end
        end

        module Staff
          module Mammals
            class Cats
            end
          end
        end
      end

      after(:all) do
        Object.send(:remove_const, :Zoo)
        Object.send(:remove_const, :Staff)
      end

      it 'finds Mammals::Cats::Lion' do
        result = ConstantVision.find_constant('Mammals::Cats::Lion')
        expect(result).to eq("Zoo::Mammals::Cats::Lion")
      end

      it 'finds Mammals::Cats' do
        result = ConstantVision.find_constant('Mammals::Cats')
        expect(result).to eq("Staff::Mammals::Cats,Zoo::Mammals::Cats")
      end
    end
  end

  describe '.find_origin_of_constant' do
    context 'when the constant is defined in the top level namespace' do
      before do
        module DummyModule
          MY_CONST = 'Test'
        end
      end

      after do
        Object.send(:remove_const, :DummyModule)
      end

      it 'finds MY_CONST' do
        result = ConstantVision.find_origin_of_constant('MY_CONST', DummyModule)
        expect(result).to eq("DummyModule::MY_CONST")
      end
    end

    context 'when the constant is defined in the top level namespace' do
      before do
        module Bar
          module Piyo
          end
        end

        module Foo
          class Bar
          end
        end
      end

      after do
        Object.send(:remove_const, :Bar)
        Object.send(:remove_const, :Foo)
      end

      it 'finds MY_CONST' do
        result = ConstantVision.find_origin_of_constant('Bar::Piyo', Foo::Bar)
        expect(result).to eq("Foo::Bar::Piyo")
      end
    end

    context 'when the constant is defined in the current namespace' do
      before do
        module Bar
          module Piyo
            module Hoge
            end
          end
        end

        module Foo
          module Bar
            class Baz
            end
          end
        end
      end

      after do
        Object.send(:remove_const, :Bar)
        Object.send(:remove_const, :Foo)
      end

      it 'finds Bar::Piyo' do
        result = ConstantVision.find_origin_of_constant('Bar::Piyo', Foo::Bar::Baz)
        expect(result).to eq("Foo::Bar::Piyo")
      end
    end

    context '別の名前空間に存在する定数を指定した場合' do
      before do
        module Zoo
          module Mammals
            module Cats
              class Lion
              end
            end
          end
        end

        module Staff
          module Mammals
            class Cats
            end
          end
        end
      end

      after do
        Object.send(:remove_const, :Staff)
        Object.send(:remove_const, :Zoo)
      end

      it 'finds Mammals::Cats' do
        result = ConstantVision.find_origin_of_constant('Mammals::Cats', 'Zoo::Mammals::Cats::Lion')
        expect(result).to eq ("Zoo::Mammals::Cats")
      end

      it 'finds Mammals::Cats::Lion' do
        result = ConstantVision.find_origin_of_constant('Mammals::Cats::Lion', 'Staff::Mammals::Cats')
        expect(result).to eq ("Staff::Mammals::Cats::Lion")
      end

      it 'finds Zoo::Mammals' do
        result = ConstantVision.find_origin_of_constant('Zoo::Mammals', 'Staff::Mammals::Cats')
        expect(result).to eq ("Zoo::Mammals")
      end

      it 'finds Mammals::Cats' do
        result = ConstantVision.find_origin_of_constant('Mammals::Cats', 'Staff::Mammals::Cats')
        expect(result).to eq ("Staff::Mammals::Cats")
      end

      it 'finds ::Zoo::Mammals' do
        result = ConstantVision.find_origin_of_constant('::Zoo::Mammals', 'Staff::Mammals::Cats')
        expect(result).to eq ("::Zoo::Mammals")
      end

      it 'finds Mammals::Cats' do
        result = ConstantVision.find_origin_of_constant('Mammals::Cats', 'Staff::Mammals::Cats')
        expect(result).to eq ("Staff::Mammals::Cats")
      end
    end

    context 'in superclass' do
      before do
        class Cats
          CRY = 'meow'
        end

        class Lion < Cats; end
      end

      after do
        Object.send(:remove_const, :Cats)
        Object.send(:remove_const, :Lion)
      end

      it 'finds CRY' do
        result = ConstantVision.find_origin_of_constant('CRY', Lion)
        expect(result).to eq ("Lion::CRY")
      end
    end
  end
end
