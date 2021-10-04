-- envo.moon - persistent environment variables
-- SFZILabs 2021

pcall makefolder, 'envo'
unless isfolder 'envo'
	rconsoleerr 'envo: could not create folder!'
	return

import crypt from syn
import derive, random, base64 from crypt
import encrypt, decrypt from crypt.custom

HttpService = game\GetService 'HttpService'

JSON =
	stringify: HttpService\JSONEncode
	parse: HttpService\JSONDecode

Keyer = (Namespace) ->
	(Key) -> 
		Name = Key .. '.json'
		Base = './envo/' .. Namespace .. '_'
		Base .. Name

isValidFile = (Path) ->
	S, E = pcall isfile, Path
	S and E

Envo = (Namespace, Key) ->
	assert (type Namespace) == 'string', 'envo: namespace is required! (string)'
	assert (type Key) == 'string', 'envo: key is required! (string)'

	keyer = Keyer Namespace
	SK = derive Key, 32

	Environment = {}
	setmetatable {}, 
		__index: (K) =>
			assert (type K) == 'string', 'envo: key must be a string!'
			if V = Environment[K]
				return V

			Path = keyer K
			return unless isValidFile Path
			Content = readfile Path
			S, Package = pcall JSON.parse, Content
			if S and (type Package) == 'table'
				IV = base64.decode Package.IV
				S, PT = pcall decrypt, 'aes-gcm', Package.CT, SK, IV
				S2, Pair = pcall JSON.parse, PT
				if S and S2
					if Pair.Key == K
						V = Pair.Value
						Environment[K] = V
						return V

			pcall delfile, Path
			nil

		__newindex: (K, V) =>
			assert (type K) == 'string', 'envo: key must be a string!'
			Old = Environment[K]
			if Old == V
				return unless V == nil

			Path = keyer K

			if V == nil
				Environment[K] = nil
				pcall delfile, Path
				return

			Value = tostring V
			Environment[K] = Value

			Content = JSON.stringify {
				Key: K
				:Value
			}

			IV = random 32
			CT = encrypt 'aes-gcm', Content, SK, IV

			Package = JSON.stringify {
				IV: base64.encode IV
				:CT
			}
			
			pcall writefile, Path, Package

getgenv!.Envo = Envo
Envo
