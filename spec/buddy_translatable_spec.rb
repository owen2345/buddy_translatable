# frozen_string_literal: true

RSpec.describe BuddyTranslatable do

  describe 'translatable' do
    let(:title) { { en: 'en', de: 'de' } }
    let(:model) { TestModel.create!(title: title) }

    describe 'getters' do
      it 'get by key locale method' do
        expect(model.title_en).to eq 'en'
      end

      it 'get by param locale value' do
        expect(model.title_data_for(:en)).to eq 'en'
        expect(model.title_for(:en)).to eq 'en'
      end

      it 'return current locale by attr name' do
        I18n.with_locale(:en) do
          expect(model.title).to eq 'en'
        end
        I18n.locale = :de
        expect(model.title).to eq 'de'
      end

      it 'return specific language' do
        expect(model.title_data_for(:en)).to eq 'en'
        expect(model.title_data_for(:de)).to eq 'de'
      end

      it 'call as method for specific lang' do
        expect(model.title_en).to eq 'en'
        expect(model.title_de).to eq 'de'
      end

      it 'return default value if missing lang' do
        expect(model.title_data_for(:es)).to eq 'de'
      end

      it 'return full data' do
        expect(model.title_data).to include title
      end

      it 'return first value if no value for default_key' do
        model.update(title: { de: '', en: 'first val' })
        expect(model.title_data_for(:it)).to eq model.title_en
      end
    end

    describe 'setters' do
      it 'update/replace full data' do
        new_title = { de: 'dee', es: 'es' }
        model.update(title: new_title)
        expect(model.reload.title_data).to include new_title
      end

      it 'update only current locale' do
        new_en_val = 'en_val'
        de_val = model.title_de
        I18n.with_locale(:en) do
          model.update(title: new_en_val)
        end
        expect(model.reload.title_en).to eq new_en_val
        expect(model.reload.title_de).to eq de_val
      end
    end
  end

  describe 'sales_datable' do
    let(:key) { { vev: 'vev', ebay: 'ebay' } }
    let(:model) { TestModel.create!(key: key) }
    before do
      BuddyTranslatable.config.available_sales_keys = %i[vev ebay]
    end

    describe 'getters' do
      it 'get by key locale method' do
        expect(model.key_vev).to eq 'vev'
      end

      it 'get by param sale_key value' do
        expect(model.key_data_for(:ebay)).to eq 'ebay'
        expect(model.key_for(:ebay)).to eq 'ebay'
      end

      it 'get default key if not exist (defined in model attr)' do
        model.update(key: { vev: 'vev' })
        expect(model.key_ebay).to eq 'vev'
      end

      it 'return specific key' do
        expect(model.key_data_for(:vev)).to eq 'vev'
      end

      it 'call as method for specific key' do
        expect(model.key_ebay).to eq 'ebay'
      end

      it 'return full data' do
        expect(model.key_data).to include key
      end

      it 'return val according to current sales key' do
        BuddyTranslatable.config.current_sales_key = :vev
        expect(model.key).to eq 'vev'
        BuddyTranslatable.config.current_sales_key = :ebay
        expect(model.key).to eq 'ebay'
      end
    end

    describe 'setters' do
      it 'update/replace full data' do
        new_key = { ebay: 'eb', vev: 've' }
        model.update(key: new_key)
        expect(model.reload.key_data).to include new_key
      end

      it 'update only current defined key' do
        new_ebay_val = 'ebay_val'
        vev_val = model.key_vev
        BuddyTranslatable.config.current_sales_key = :ebay
        model.update(key: new_ebay_val)
        expect(model.reload.key_ebay).to eq new_ebay_val
        expect(model.reload.key_vev).to eq vev_val
      end
    end
  end
end
