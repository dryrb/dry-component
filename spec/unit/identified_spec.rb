require 'dry/system/identified'

RSpec.describe Dry::System::Identified do
  subject(:identified) { Dry::System::Identified.new(identifier, namespace: namespace) }

  let(:full_identifier) { [] }
  let(:identifier) { full_identifier }
  let(:full_namespace) { [] }
  let(:namespace) { full_namespace.empty? ? nil : full_namespace }

  context 'simple identifier' do
    let (:identifier) { :foo }

    specify { expect(identified.identifier).to eq(:foo) }
    specify { expect(identified.namespace).to be(nil) }
    specify { expect(identified.root_key).to be(nil) }
  end

  context 'compound identifier' do
    let(:full_identifier) { [:foo, :bar] }

    shared_examples 'a compound identifier' do
      specify { expect(identified.identifier).to eq('foo.bar') }
      specify { expect(identified.namespace).to be(nil) }
      specify { expect(identified.root_key).to eq(:foo) }
    end

    context 'as a string' do
      let(:identifier) { full_identifier.join('.') }
      it_behaves_like 'a compound identifier'
    end

    context 'as an array' do
      let(:identifier) { full_identifier }
      it_behaves_like 'a compound identifier'
    end
  end

  context 'when namespaced' do
    shared_examples 'a namespaced identifier' do
      context 'matching the root key' do
        let(:full_identifier) { [:foo, :bar] }
        let(:full_namespace) { [:foo] }

        specify { expect(identified.identifier).to eq(:bar) }
        specify { expect(identified.namespace).to eq(:foo) }
        specify { expect(identified.path).to eq('foo/bar') }
      end

      context 'different from the root key' do
        let(:full_identifier) { [:bar, :baz] }
        let(:full_namespace) { [:foo] }

        specify { expect(identified.identifier).to eq('bar.baz') }
        specify { expect(identified.namespace).to eq(:foo) }
        specify { expect(identified.path).to eq('bar/baz') }
      end

      context 'compound namespace' do
        let(:full_identifier) { [:foo, :bar, :baz] }
        let(:full_namespace) { [:foo, :bar] }

        specify { expect(identified.identifier).to eq(:baz) }
        specify { expect(identified.namespace).to eq('foo.bar') }
        specify { expect(identified.path).to eq('foo/bar/baz') }
      end
    end

    context 'as a string' do
      let(:namespace) { full_namespace.join('.') }
      it_behaves_like 'a namespaced identifier'
    end

    context 'as an array' do
      it_behaves_like 'a namespaced identifier'
    end
  end

  describe '#prepend' do
    specify do
      expect(Dry::System::Identified.new([:bar], namespace: [:foo]).prepend(:foo))
        .to eq(Dry::System::Identified.new([:foo, :bar], namespace: [:foo]))
    end
  end

  describe '#namespaced' do
    specify do
      expect(Dry::System::Identified.new([:bar], namespace: nil).namespaced(:foo))
        .to eq(Dry::System::Identified.new([:foo, :bar], namespace: [:foo]))
    end
  end
end

