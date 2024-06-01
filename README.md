# Goventure  

## About  

Goventure is a Godot plugin that helps with creating point-and-click adventure games.  
It provides a simple to use visual editor that enables you to define any number of actions and their behaviour by connecting command nodes.  

## Installation  

Head to the [release page](https://github.com/bene-labs/Goventure/releases) and pick your preferred version of the plugin. (Using the latest version is always recommended.) 

Goventure uses the Dialogic plugin to display dialogues. If you plan to add your own dialogue boxes you can pick the solo version of the plugin, but the version including Dialogic is recommended. 

<img width="494" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/986a61c2-02c3-42d5-8371-8cdcacb180e4"> 

After downloading the plugin extract the zip and move the resulting addons folder into the root directory of your godot project. 
If your project already includes a addon folder choose "Replace the files in the destination".  

<span><img width="323" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/4704cbe5-ce58-4040-9d0f-83b9829ff11c"></span> 

After opening your project head to ``Project>Project Settings>Plugins`` and enable the plugin by clicking the checkbox.<img width="494" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/059d7e01-8fc9-47dd-948c-57dc8258a9b1"> 

Reload the project to load the plugin and the installation is complete. You can do this via ``Project>Reload Current Project`` or by simply closing and reopening the project manually. 

## Usage 

### Defining Actions and Interactibles 

Interactibles are all object types that can be interacted with while the action are all the actions that can be perfomed with an on the interactibles. 

To add, remove or adjust your actions head to the Goventure Editor window and got to the ``Actions`` tab. 

<img width="428" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/c0aa66a3-ba0a-4279-9897-d20c2ceba358"> 

You can add new actions via the ``Add new Action`` Button and delete an actions by pressing the button with the trashcan icon. 

To change the name of an action, click on the ``Action Name`` input field. You can also adjust the combination type of an action by pressing the option button on the right. Each Combination Type has a tooltip explaining its meaning. 

To add, remove or adjust your interactibles head to the ``Interactibles`` tab in the same window. 

<img width="428" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/375e4828-0463-4ad0-b5b1-7f1a64bf3a06"> 

You can change the name of an Interactible by clicking on it and add and remove them the same way as the actions. 
Any change you make in the Goventure Window is saved automatically. 

*** 
Please note: each action and interactible name can only be used once and you must always have at least one action and one interactible. 
*** 

### Using Interactibles 

To add a new Interactible create the provided Node of the same name. 

<img width="425" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/18a22dae-0a70-4997-a09e-b4a11feba7f3"> 

You can choose any of the interactible names you definied in the ``Interactibles`` tab as an ID. Simply click on the ID field in the Inspector to change it. 

<img width="178" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/f9f65b90-dfa1-49e3-bd4a-85d850baa367"> 

To determine what should happen when any actions are used with this interactible click the ``open in Editor`` button in the Inspector to start the Visual Interaction Editor. 

<img width="173" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/21460083-e671-4a4d-bb48-12eea8ce955c"> 

### Using the Visual Interaction Editor 

The Visual Interaction Editor is started by clicking the "open in Editor" button on the Interactible you want to edit. 

The Interaction Editor works by linking the outputs of nodes with the inputs of matching nodes to define the command that should be run when actions are used with interactibles. 
To add a Node click the corresponding button on the left of the screen and drag the node to the desired location. To let go of the new node press the right mouse button. 

#### Control overview 

| To archive     | Do                                         | 
|----------------|--------------------------------------------| 
| Add Cable      | ``Left Mouse`` on connection               | 
| Add Node       | Click corresponding button                 | 
| Move Element   | Hold ``Right Mouse`` and drag it           | 
| Remove element | Press ``Delete`` while hovering it         | 
| Move Camera    | Press ``Middle Mouse`` and drag the cursor | 
| Zoom in/out    | Rotate mouse wheel                         | 

  

#### Node Types 

##### Base Node 

This Node defines an interactible and provides all actions that are compatible with it as outputs. To choose which interactible you want to use click on the selection field on the top left of the Node. 

<img width="98" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/2adc5151-4f70-4e9e-8e85-4e1fd9113bb9"> 

##### Combination Node 

This node enables you to do an action from a base node with another interactible. You can choose with action you want to combine your action with by clicking the selection field in the middle of the node. 

<figure> 
  <img width="300" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/37c9b3ff-dfdb-42cb-856f-a4861dfdfce2"> 
  <div>
  <figcaption> <span style="font-size:0.5em;">Example: The key is used with a lock.</span></figcaption></span> 
</figure> 

##### Dialogue Node 

A Dialogue Node defines a Text that should appear when an action is done. 
To provide the content of a Dialogue click on the textbox inside it and type your text. You can copy text via ``Ctrl+C``, paste text via ``Ctrl+V`` and cut text via ``Ctrl+X``. 
You can chain any number of Dialogue Nodes to togheter to make multiple lines of Dialogue appear that the player has to click through one after another. 

<img width="746" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/e55c9d60-0a17-4a96-bd36-d7599c55ac06"> 

##### Random Node 

The Random Node will continue the command path at a random output. You can add and remove ouputs by using the ``+`` and ``-`` buttons on the bottom right. 
To adjust the liklehood that a certain output will be picked you can pres the ``+`` and ``-`` buttons next to each node. The liklehood of each output is always displayed to its left. 

<figure> 
 <img width="488" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/197332ad-b0d5-411d-be68-8540786dc7db"> 
 <div> 
 <figcaption><span style="font-size:0.5em;"> Example: Using a can opener with a rock has a 5 in 11 chance to either result in the "I don't want to." or the "I'd rather not." dialogue. The "Great Idea" Dialogue will only trigger in 1 out of 11 times when doing the action.</span></figcaption> 
</figure> 

##### Sequence Node 

The Sequence Node allows you to trigger different dialogues whenever the same action is repeated. Output 1 will be used the first time the node is reached, Output 2 on the second time and so on.  
You can determine what should happen once the final output is reached by clicking on the drop-down menu on the bottom left. The options are as follows: ``Start over`` to continue from the top-most output, ``Repeat last`` to repeat the bottom-most output indefinitely and ``Stop`` to ignore any further incoming signals. 
Outputs can be added and removed the same way as the Random Node. 

<figure> 
 <img width="657" alt="image" src="https://github.com/bene-labs/Goventure/assets/62158116/523b01fe-0d88-4a41-9ac2-384a923bf5e2"> 
 <div> 
 <figcaption><span style="font-size:0.5em;"> Example: Repeatly trying to use a can opener with a rock result in increasingly annoyed responses. </span></figcaption> 
</figure> 

### Running the Visual Script 

To run the actions that were definied inside the visual scripting editor you can use the ``do_action`` function inside the interactible class. It takes up to two arguments: ``action`` is the name of the action that you want to use and is always required, ``with`` is the interactible that you want to use it with and is optional. 
To test out the behaviour of your linked interactions you can also use the ``inventory_test`` scene that is provided with the plugin. 
