require 'yaml'

LANG ||= 'us' # pour le moment
MSG_PATH = File.join(__dir__, 'locales', LANG)
ERRORS = YAML.safe_load(File.read(File.join(MSG_PATH,'errors.yml')))
MESSAGES = YAML.safe_load(File.read(File.join(MSG_PATH,'messages.yml')))


def Err(errId, errParams = nil)
  errParams ||= []
  ERRORS[errId] % errParams
end

def Msg(msgId, msgParams = nil)
  msgParams ||= []
  MESSAGES[msgId] % msgParams
end