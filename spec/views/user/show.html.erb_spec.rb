require 'rails_helper'

RSpec.describe 'users/show', type: :view do
  context 'when current_user' do
    before do
      current_user = assign(:user, build_stubbed(:user, name: 'Username'))
      allow(view).to receive(:current_user).and_return(current_user)
      assign(:games, [build_stubbed(:game)])
      stub_template 'users/_game.html.erb' => 'User game goes here'

      render
    end

    it 'renders players name' do
      expect(rendered).to match 'Username'
    end

    it 'checks the rendering of the password and username change button' do
      expect(rendered).to match 'Сменить имя и пароль'
    end

    it 'checks a game partial' do
      expect(rendered).to match 'User game goes here'
    end
  end

  context 'when not current_user' do
    before do
      assign(:user, build_stubbed(:user, name: 'AnotherUser'))

      render
    end

    it 'renders players name' do
      expect(rendered).to match('AnotherUser')
    end

    it 'checks the rendering of the password and username change button' do
      expect(rendered).not_to match 'Сменить имя и пароль'
    end
  end
end
