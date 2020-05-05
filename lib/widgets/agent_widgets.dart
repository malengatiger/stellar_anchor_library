import 'package:flutter/material.dart';
import 'package:stellar_anchor_library/bloc/agent_bloc.dart';
import 'package:stellar_anchor_library/models/agent.dart';
import 'package:stellar_anchor_library/models/client.dart';
import 'package:stellar_anchor_library/util/functions.dart';

import 'avatar.dart';

class AgentClientsWidget extends StatelessWidget {
  final Agent agent;

  const AgentClientsWidget({Key key, @required this.agent}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    agentBloc.getClients(agentId: agent.agentId);
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 12, right: 16),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 60,
                child: MyAvatar(
                  icon: Icon(
                    Icons.people,
                    color: Colors.pink,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Text("Clients"),
                  SizedBox(
                    width: 20,
                  ),
                  StreamBuilder<List<Client>>(
                      stream: agentBloc.clientStream,
                      builder: (context, snapshot) {
                        var total = 0;
                        if (snapshot.hasData) {
                          total = snapshot.data.length;
                        }
                        return Text(
                          '$total',
                          style: Styles.blueBoldMedium,
                        );
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AgentLoans extends StatelessWidget {
  final Agent agent;

  const AgentLoans({Key key, this.agent}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    agentBloc.getClients(agentId: agent.agentId);
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 12, right: 16),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 60,
                child: MyAvatar(
                  icon: Icon(
                    Icons.account_balance,
                    color: Colors.blue,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Text("Client Loans"),
                  SizedBox(
                    width: 20,
                  ),
                  StreamBuilder<List<Client>>(
                      stream: agentBloc.clientStream,
                      builder: (context, snapshot) {
                        var total = 0;
                        if (snapshot.hasData) {
                          total = snapshot.data.length;
                        }
                        return Text(
                          '$total',
                          style: Styles.blueBoldMedium,
                        );
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class AgentLoanPayments extends StatelessWidget {
  final Agent agent;

  const AgentLoanPayments({Key key, this.agent}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    agentBloc.getClients(agentId: agent.agentId);
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 12, right: 16),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 60,
                child: MyAvatar(
                  icon: Icon(
                    Icons.attach_money,
                    color: Colors.teal,
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Text("Payments"),
                  SizedBox(
                    width: 20,
                  ),
                  StreamBuilder<List<Client>>(
                      stream: agentBloc.clientStream,
                      builder: (context, snapshot) {
                        var total = 0;
                        if (snapshot.hasData) {
                          total = snapshot.data.length;
                        }
                        return Text(
                          '$total',
                          style: Styles.blueBoldMedium,
                        );
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
