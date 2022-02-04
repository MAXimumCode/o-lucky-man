require 'rails_helper'

RSpec.feature 'USER looks another user profile', type: :feature do
  let(:user1) { create(:user, name: 'User1') }
  let(:user2) { create(:user, name: 'User2') }

  let!(:games) do
    [
      create(:game, user: user2, current_level: 10, created_at: Time.parse('04.02.2022, 22:00')),
      create(:game, user: user2, prize: 1_000_000, current_level: 15, created_at: Time.parse('05.02.2022, 22:00'),
                    finished_at: Time.parse('05.02.2050, 22:30'))
    ]
  end

  before do
    login_as user1
  end

  scenario 'User1 looks User2 profile' do
    visit '/'

    click_link 'User2'

    expect(page).not_to have_content 'Сменить имя и пароль'
    expect(page).to have_content 'User2'

    expect(page).to have_content '#'
    expect(page).to have_content 'Дата'
    expect(page).to have_content 'Вопрос'
    expect(page).to have_content 'Выигрыш'
    expect(page).to have_content 'Подсказки'

    expect(page).to have_content '2'
    expect(page).to have_content 'в процессе'
    expect(page).to have_content '04 февр., 22:00'

    expect(page).to have_content 'победа'
    expect(page).to have_content '05 февр., 22:00'
    expect(page).to have_content '15'
    expect(page).to have_content '1 000 000 ₽'
  end
end