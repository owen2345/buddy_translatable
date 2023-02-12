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

      it 'sets values for a specific locale' do
        de_value = 'custom de value'
        model.update!(title_de: de_value)
        expect(model.title_de).to eq(de_value)
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

  describe 'when filtering' do
    before { TestModel.delete_all }

    describe 'when DB supports jsonb format' do
      let!(:record1) { TestModel.create!(title: { en: 'Sample EN 1', de: 'Sample DE 1' }) }
      let!(:record2) { TestModel.create!(title: { en: 'Sample eN 2', de: 'Sample DE 2' }) }
      let!(:record3) { TestModel.create!(title: { en: 'Example EN 3', de: 'Example DE 3' }) }

      it 'filters for an exact value in any locale' do
        I18n.locale = :en
        expect(TestModel.where_title_with('Sample DE 2')).to eq([record2])
      end

      it 'filters for any locale that contains the provided value' do
        I18n.locale = :en
        expect(TestModel.where_title_like('Sample DE')).to match_array([record1, record2])
      end

      it 'filters for items where current locale has the exact provided value' do
        I18n.locale = :en
        expect(TestModel.where_title_eq('Sample EN 1')).to match_array([record1])
        expect(TestModel.where_title_eq('Sample DE 1')).to eq([])
      end
    end

    describe 'when DB does not support jsonb format' do
      let!(:record1) { TestModel.create!(title_text: { en: 'Sample EN 1', de: 'Sample DE 1' }) }
      let!(:record2) { TestModel.create!(title_text: { en: 'Sample eN 2', de: 'Sample DE 2' }) }
      let!(:record3) { TestModel.create!(title_text: { en: 'Example EN 3', de: 'Example DE 3' }) }

      it 'filters for an exact value in any locale' do
        I18n.locale = :en
        expect(TestModel.where_title_text_with('Sample DE 2')).to eq([record2])
      end

      it 'filters for any locale that contains the provided value' do
        I18n.locale = :en
        expect(TestModel.where_title_text_like('Sample DE')).to match_array([record1, record2])
      end

      it 'filters for items where current locale has the exact provided value' do
        I18n.locale = :en
        expect(TestModel.where_title_text_eq('Sample EN 1')).to match_array([record1])
        expect(TestModel.where_title_text_eq('Sample DE 1')).to eq([])
      end
    end
  end
end
