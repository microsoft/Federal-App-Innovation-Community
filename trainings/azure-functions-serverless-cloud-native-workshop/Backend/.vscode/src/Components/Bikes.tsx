import React, { FunctionComponent } from "react";
import Bike from "../Models/Bikes";
import { Stack, IStackItemStyles, DefaultButton, IStackStyles, DocumentCard, Label, PrimaryButton, Panel, TextField, MaskedTextField } from "office-ui-fabric-react";

interface IBikes {
    m_aBike: Bike[];    
    m_bEditOpen: boolean;
    m_SelectedBike: Bike;
    m_nNewQuantity: number;
    m_bAddOpen: boolean;
  }

  const itemStyles: React.CSSProperties = {
    alignItems: 'start',
    display: 'flex',
    justifyContent: 'start',
    width: 150,
    padding: 10
  };

  const lblStyle: React.CSSProperties = {
   fontSize: 20
  };

  const pnlStyle: React.CSSProperties = {
    margin:5,
    width: 200
   };

export default class Bikes extends React.Component<{  }, IBikes>
{
    constructor(props: Readonly<{}>) {
        super(props);
    
        this.state =
        {         
          m_aBike: new Array(),
          m_bEditOpen: false,
          m_SelectedBike: new Bike(),
          m_nNewQuantity: 0,
          m_bAddOpen: false
        };    
      }
      
    componentDidMount() 
    {
        fetch('https://htgtfrfeesrfrf.azurewebsites.net/api/Bikes?code=BWkQ0OEPspbxEQPtX4N6Q0%2FqSDMZBiFgvF2QnnBXYTBugGGUgcuG1g%3D%3D')
            .then(res => res.json())
            .then(res => {
                 this.setState({ m_aBike: res });
        });    
    }   

    ShowEdit(b: Bike)
    {
        this.setState({m_SelectedBike: b, m_nNewQuantity: b.quantity, m_bEditOpen: true});       
    }

    CloseEdit()
    {
        this.setState({m_bEditOpen: false});
    }

    Save()
    {
        let v: Bike = this.state.m_SelectedBike;
        v.quantity = this.state.m_nNewQuantity;

        fetch("https://htgtfrfeesrfrf.azurewebsites.net/api/Bike?code=/F6dCDY8WHbP3FQzmYNYgp/lug7fe2joXjCbN9LZ3tre8KH0XW3iQg==", {
            method: 'post',
            body: JSON.stringify(v)
        }).then(res => {
            window.location.href = '/';
        }).catch(error => alert('Error! ' + error.message));

        this.setState({m_bEditOpen: false});
    }

    QuantityChange = (event: { target: { value: any; }; }) => {        
        this.setState({ m_nNewQuantity: event.target.value });
      }

    AddMakeChange = (event: { target: { value: any; }; }) => {        
        let v: Bike = this.state.m_SelectedBike;
        v.make = event.target.value;
        this.setState({ m_SelectedBike: v });
    }
    
    AddModelChange = (event: { target: { value: any; }; }) => {        
        let v: Bike = this.state.m_SelectedBike;
        v.model = event.target.value;
        this.setState({ m_SelectedBike: v });
    }

    AddPriceChange = (event: { target: { value: any; }; }) => {        
        let v: Bike = this.state.m_SelectedBike;
        v.price = event.target.value;
        this.setState({ m_SelectedBike: v });
    }

    AddQuantityChange = (event: { target: { value: any; }; }) => {        
        let v: Bike = this.state.m_SelectedBike;
        v.quantity = event.target.value;
        this.setState({ m_SelectedBike: v });
    }

    CloseAdd()
    {
        this.setState({m_bAddOpen: false});       
    }

    ShowAdd()
    {
        this.setState({m_bAddOpen: true});       
    }
    
    Add()
    {
        fetch("https://htgtfrfeesrfrf.azurewebsites.net/api/Bike?code=/F6dCDY8WHbP3FQzmYNYgp/lug7fe2joXjCbN9LZ3tre8KH0XW3iQg==", {
            method: 'post',
            body: JSON.stringify(this.state.m_SelectedBike)
        }).then(res => {
            window.location.href = '/';
        }).catch(error => alert('Error! ' + error.message));

        this.setState({m_bAddOpen: false});
    }

    RenderBike(b: Bike)
    {
        var formatter = new Intl.NumberFormat('en-US', {
            style: 'currency',
            currency: 'USD',
          });

        return <Stack horizontal>
            <Label style={itemStyles}>{b.make}</Label>
            <Label style={itemStyles}>{b.model}</Label>
            <Label style={itemStyles}>{formatter.format(b.price)}</Label>
            <Label style={itemStyles}>{b.quantity}</Label>
            <PrimaryButton text="Edit" onClick={() => this.ShowEdit(b)}  allowDisabledFocus />
        </Stack>
    }

    render() {
            return (
                <Stack padding={10}>
                    <Label style={lblStyle}>Current Bikes</Label>
                    <Stack>
                        {this.state.m_aBike.map(v => this.RenderBike(v))}
                    </Stack>  


                    <Panel
                        headerText={this.state.m_SelectedBike.model}
                        isOpen={this.state.m_bEditOpen}                        
                        closeButtonAriaLabel="Close">
                        <Stack>
                            <TextField style={pnlStyle} label="Quantity" onChange={this.QuantityChange.bind(this)} value={this.state.m_nNewQuantity} />
                            <PrimaryButton style={pnlStyle} text="Save" onClick={() => this.Save()} allowDisabledFocus />
                            <PrimaryButton style={pnlStyle} text="Close" onClick={() => this.CloseEdit()} allowDisabledFocus />
                        </Stack>
                    </Panel>

                    <Panel
                        headerText="New Bike"
                        isOpen={this.state.m_bAddOpen}                        
                        closeButtonAriaLabel="Close">
                        <Stack>

                            <TextField style={pnlStyle} label="Make" onChange={this.AddMakeChange.bind(this)}/>
                            <TextField style={pnlStyle} label="Model" onChange={this.AddModelChange.bind(this)}/>

                            <TextField style={pnlStyle} label="Price" onChange={this.AddPriceChange.bind(this)}/>
                            <TextField style={pnlStyle} label="Quantity" onChange={this.AddQuantityChange.bind(this)}/>

                            <PrimaryButton style={pnlStyle} text="Add" onClick={() => this.Add()} allowDisabledFocus />
                            <PrimaryButton style={pnlStyle} text="Close" onClick={() => this.CloseAdd()} allowDisabledFocus />
                        </Stack>
                    </Panel>

                    <PrimaryButton style={pnlStyle} text="Add" onClick={() => this.ShowAdd()}  allowDisabledFocus />


                </Stack>
        );
    }
}
