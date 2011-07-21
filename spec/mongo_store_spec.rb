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

  describe "complex write" do

    before { store.store_translations(:en, {:foo => {'bar'=>'baz', 'alpha'=>{'bravo'=>'charlie'}}}) }

    subject { store.fetch(:en,:foo)}

    it "the retrieved object has decendant methods " do
      subject.bar.should == 'baz'
      subject.alpha.bravo.should == 'charlie'
    end

    it "the retrieved object is also a Hash " do
      subject[:bar].should == 'baz'
      subject[:alpha].should be_kind_of Hash
    end

  end

  describe "listing the locales" do
    before do
      store.store_translations(:en, {'alpha'=>'bravo'})
      store.store_translations(:de, {'alpha'=>'charlie'})
      store.store_translations(:fr, {'alpha'=>'delta'})
    end

    subject { store.available_locales()}

    it {should == [:en,:de,:fr]}
  end
end

describe "i18n integration" do
  let(:collection)  { DB.collection('mongo_i18n') }
  let(:store)       { ::I18n::Backend::MongoStore.new(collection) }

  before do
    I18n.backend = store
    DB.collections.each do |collection|
      collection.remove
      collection.drop_indexes
    end
  end

  describe "using I18n to translate" do
    before do
      store.store_translations(:en, {'alpha'=>'bravo'})
      store.store_translations(:de, {'alpha'=>'charlie'})
      store.store_translations(:fr, {'alpha'=>'delta'})
    end

    subject { 'alpha' }

    it "should translate for locale en" do
      I18n.locale = :en
      I18n.t(subject).should == 'bravo'
    end

    it "should translate for locale de" do
      I18n.locale = :de
      I18n.t(subject).should == 'charlie'
    end

    it "should translate for locale fr" do
      I18n.locale = :fr
      I18n.t(subject).should == 'delta'
    end

  end
  
end


