#####| Plataforma do crowdfundiong do projeto Alfa v1 |#####
#####|    Meta: 100 Ethers    Prazo: 10000 segundos   |#####
#####|  Quem der deploy no contrato é o beneficiario  |#####

###| Perfil de cada doador
donator: public(HashMap[address, uint256])

###| Endereço do dono do contrato
owner: address

###| Meta de arrecadação
objective: uint256

###| Arrecadado até agora
collected: uint256

###| Indica se a meta foi batida ou não
reached: bool

###| Tempo limite pro Crowdfunding rolar
endtime: uint256

###| Construtor
@external
def __init__(objective: uint256, limit: uint256):
    self.owner = msg.sender
    self.objective = objective
    self.collected = 0
    self.reached = False
    self.endtime = block.timestamp + limit

###| Função que faz a doação
@external
@payable
def donate():

    ##| Testa se o tempo para doações ainda não acabou
    assert self.endtime >= block.timestamp, "The crowdfunding has ended"

    ##| Testa se a doação é maior que 0
    assert msg.value > 0, "Your donation must be more than 0"
    
    ##| Atualiza variavel de quanto foi arrecadado no total
    self.collected += msg.value

    ##| Atualiza a doação referente a carteira do doador
    self.donator[msg.sender] += msg.value

    ##| Checa se atingiu a meta de doações
    if self.collected >= self.objective:
        self.reached = True

###| Pede para receber a grana de volta caso a meta não seja batida
@external
def askRefund():

    ##| Testa se o doador já doou
    assert self.donator[msg.sender] > 0, "Your don't have donated anything'"
    
    ##| Testa se o evento já acabou
    assert self.endtime < block.timestamp, "The crowdfunding hasn't ended"

    ##| Testa se a meta foi atingida
    assert self.reached == False, "You cannot get a refund cause the donations reached the goal"
    
    ##| Subtrai o valor da doação
    self.collected -= self.donator[msg.sender]

    ##| Devolve o dinheiro
    send(msg.sender, self.donator[msg.sender])

    self.donator[msg.sender] = 0

###| Função que encerra as doações
@external
def finish():

    ##| Testa se o tempo para doações ainda não acabou
    assert self.endtime < block.timestamp, "You only can only end it after the endtime"

    ##| Testa se é o dono do contrato
    assert msg.sender == self.owner, "You're not the owner"
    
    ##| Se a meta foi atingida saca o dinheiro do contrato
    assert self.reached == True or self.collected == 0, "The funding hasn't reached the goal and someone hasn't got his refund"

    ##| Envia a grana pro owner
    send(self.owner, self.balance)

    ##| Destroi o contrato
    selfdestruct(self.owner)
    

####| Funções abaixo usadas apenas para DEBUG logo |####
####| não são necessárias no projeto final         |####

###| Função para ver o próprio saldo
@external
@view
def ZuserDonator() -> uint256:
    return self.donator[msg.sender]

###| Função para ver o total de doações
@external
@view
def ZallDonator() -> uint256:
    return self.collected

###| Função para ver se foi atingido o valor
@external
@view
def ZcheckReached() -> bool:
    return self.reached

###| Função para ver a hora limite
@external
@view
def ZcheckEndtime() -> uint256:
    return self.endtime

###| Função para ver a hora atual
@external
@view
def ZcheckTimeNow() -> uint256:
    return block.timestamp
