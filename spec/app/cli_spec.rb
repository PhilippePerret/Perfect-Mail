RSpec.describe 'perfect-mail CLI', type: :aruba do
  it 'displays help message when run without arguments' do
    run_command('perfect-mail')
    expect(last_command_started).to be_successfully_executed
    expect(last_command_started).to have_output(/Usage:/)
  end
end