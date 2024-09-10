import React, { useState } from 'react';
import './App.css';
import { useMsal, useMsalAuthentication } from '@azure/msal-react';
import { InteractionType } from '@azure/msal-browser';

function App() {
  useMsalAuthentication(InteractionType.Redirect);
  const [m_strUser, setm_strUser] = useState<string>("");

  function Render() {

    const { accounts } = useMsal();

    try {
      const username = accounts[0].username;
      setm_strUser(username);
    }
    catch (e) {
    }
  }

  if (m_strUser != "")
    return (
      <div className="App">
        <div>User: {m_strUser}</div>
      </div>
    );
  else
    return <>{Render()}<div>Please wait...</div></>
}

export default App;
