require 'rails_helper'
require 'support/my_spec_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user) }
  let(:admin) { create(:user, is_admin: true) }
  let(:game_w_questions) { create(:game_with_questions, user: user) }

  # группа тестов для незалогиненного юзера (Анонимус)
  context 'Anon' do
    describe '#show' do
      it 'kick from #show' do
        get :show, params: { id: game_w_questions.id }
        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    describe '#create' do
      it 'kick from #create' do
        generate_questions(15)

        post :create
        game = assigns(:game)

        expect(game).to be_nil

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    describe '#answer' do
      it 'kick from #answer' do
        put :show, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key }

        game_w_questions.reload
        expect(game_w_questions.current_level).to eq(0)
        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(new_user_session_path)
        expect(flash[:alert]).to be
      end
    end

    describe '#take_money' do
      it 'kick from #take_money' do
       game_w_questions.update_attribute(:current_level, 2)

       put :take_money, params: { id: game_w_questions.id }

       game_w_questions.reload
       expect(game_w_questions).not_to be_finished
       expect(response.status).not_to eq(200)
       expect(response).to redirect_to(new_user_session_path)
       expect(flash[:alert]).to be
      end
    end
  end

  context 'Usual user' do
    before { sign_in user }

    describe '#create' do
      it 'creates game' do
        generate_questions(15)

        post :create
        game = assigns(:game)

        expect(game.finished?).to be false
        expect(game.user).to eq(user)
        expect(response).to redirect_to(game_path(game))
        expect(flash[:notice]).to be
      end

      it 'try to create second game' do
        expect(game_w_questions.finished?).to be false

        expect { post :create }.to change(Game, :count).by(0)

        game = assigns(:game)
        expect(game).to be_nil

        expect(response).to redirect_to(game_path(game_w_questions))
        expect(flash[:alert]).to be
      end
    end

    describe '#show' do
      it 'shows game' do
        get :show, params: { id: game_w_questions.id }
        game = assigns(:game)
        expect(game.finished?).to be false
        expect(game.user).to eq(user)

        expect(response.status).to eq(200)
        expect(response).to render_template('show')
      end

      it 'shows alien game' do
        alien_game = create(:game_with_questions)

        get :show, params: { id: alien_game.id }

        expect(response.status).not_to eq(200)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to be
      end
    end

    describe '#answer' do
      it 'answers correct' do
        put :answer, params: { id: game_w_questions.id, letter: game_w_questions.current_game_question.correct_answer_key }
        game = assigns(:game)

        expect(game.finished?).to be false
        expect(game.current_level).to be > 0
        expect(response).to redirect_to(game_path(game))
        expect(flash.empty?).to be true
      end

      it 'make incorrect answer' do
        answer_letters = %w[a b c d]
        answer_letters.delete(game_w_questions.current_game_question.correct_answer_key)

        put :answer, params: { id: game_w_questions.id, letter: answer_letters.sample }

        game = assigns(:game)

        expect(game).to be_finished
        expect(game.status).to eq :fail
        expect(game.current_level).to eq 0
        expect(response).to redirect_to user_path(user)
        expect(flash[:alert]).to be
      end
    end

    describe '#take_money' do
      it 'takes money' do
        game_w_questions.update_attribute(:current_level, 2)

        put :take_money, params: { id: game_w_questions.id }
        game = assigns(:game)
        expect(game.finished?).to be true
        expect(game.prize).to eq(200)

        user.reload
        expect(user.balance).to eq(200)

        expect(response).to redirect_to(user_path(user))
        expect(flash[:warning]).to be
      end
    end

    describe '#audience_help' do
      it 'uses audience help' do
        expect(game_w_questions.current_game_question.help_hash[:audience_help]).not_to be
        expect(game_w_questions.audience_help_used).to be false

        put :help, params: { id: game_w_questions.id, help_type: :audience_help }
        game = assigns(:game)

        expect(game.finished?).to be false
        expect(game.audience_help_used).to be_truthy
        expect(game.current_game_question.help_hash[:audience_help]).to be
        expect(game.current_game_question.help_hash[:audience_help].keys).to contain_exactly('a', 'b', 'c', 'd')
        expect(response).to redirect_to(game_path(game))
      end
    end

    describe '#fifty_fifty_help' do
      it 'uses fifty_fifty help' do
        expect(game_w_questions.current_game_question.help_hash[:fifty_fifty]).not_to be
        expect(game_w_questions.fifty_fifty_used).to be false

        put :help, params: { id: game_w_questions.id, help_type: :fifty_fifty }
        game = assigns(:game)

        correct_answer_key = game_w_questions.current_game_question.correct_answer_key

        expect(game.finished?).to be false
        expect(game.fifty_fifty_used).to be_truthy
        expect(game.current_game_question.help_hash[:fifty_fifty]).to be
        expect(game.current_game_question.help_hash[:fifty_fifty]).to include(correct_answer_key)
        expect(response).to redirect_to(game_path(game))
      end
    end
  end
end
