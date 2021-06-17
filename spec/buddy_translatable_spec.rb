# frozen_string_literal: true

RSpec.describe BuddyTranslatable do
  let(:title) { { en: 'en', de: 'de' } }
  let(:model) { TestModel.create!(title: title, title_text: title) }

  describe 'when jsonb format' do
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

  describe 'when text attributes' do
    let(:en_value) { 'En Value' }

    it 'returns correct value when getting value' do
      expect(model.title_text_en).to eq 'en'
    end

    it 'sets correct value when setting value' do
      I18n.locale = :en
      model.title_text = en_value
      expect(model.title_text).to eq en_value
    end

    it 'sets correct data value when setting data' do
      data = { en: 'custom en value', de: 'Custom de value' }
      model.title_text_data = data
      expect(model.title_text_data).to eq data
    end

    it 'returns correct data' do
      model.reload
      expect(model.title_text_data).to eq title
    end

    it 'returns correct data when saved and reloaded' do
      I18n.locale = :en
      model.update!(title_text: en_value)
      model.reload
      expect(model.title_text_data[:en]).to eq en_value
    end
  end
end
