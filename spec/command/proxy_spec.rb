require File.expand_path('../../spec_helper', __FILE__)

module Pod
  describe Command::Proxy do
    describe 'CLAide' do
      it 'registers it self' do
        Command.parse(%w{ proxy }).should.be.instance_of Command::Proxy
      end
    end
  end
end

