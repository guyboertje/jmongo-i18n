require 'spec_helper'

describe "MongoStore" do
  before do
    DB.collections.each do |collection|
      collection.remove
      collection.drop_indexes
    end
  end

  let(:collection)  { DB.collection('mongo_i18n') }
  let(:store)       { ::I18n::Backend::MongoStore.new(collection) }

  describe "the base class" do
    subject { store }
    its(:store) {should == collection}

    [:store_translations, :available_locales, :lookup].each do |sym|
      it { should respond_to(sym)}
    end

  end

  describe "simple write" do
    before { store.store_translations(:en, {'foo' => 'bar'}) }

    subject { store.fetch(:en,:foo)}

    it {should == "bar"}

    subject {store.lookup(:en,:foo)}
    it {should == "bar"}

  end
end