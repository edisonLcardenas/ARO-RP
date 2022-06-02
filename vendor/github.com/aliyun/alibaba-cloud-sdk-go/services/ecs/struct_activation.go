package ecs

//Licensed under the Apache License, Version 2.0 (the "License");
//you may not use this file except in compliance with the License.
//You may obtain a copy of the License at
//
//http://www.apache.org/licenses/LICENSE-2.0
//
//Unless required by applicable law or agreed to in writing, software
//distributed under the License is distributed on an "AS IS" BASIS,
//WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//See the License for the specific language governing permissions and
//limitations under the License.
//
// Code generated by Alibaba Cloud SDK Code Generator.
// Changes may cause incorrect behavior and will be lost if the code is regenerated.

// Activation is a nested struct in ecs response
type Activation struct {
	DeregisteredCount int    `json:"DeregisteredCount" xml:"DeregisteredCount"`
	InstanceCount     int    `json:"InstanceCount" xml:"InstanceCount"`
	RegisteredCount   int    `json:"RegisteredCount" xml:"RegisteredCount"`
	TimeToLiveInHours int64  `json:"TimeToLiveInHours" xml:"TimeToLiveInHours"`
	ActivationId      string `json:"ActivationId" xml:"ActivationId"`
	Disabled          bool   `json:"Disabled" xml:"Disabled"`
	InstanceName      string `json:"InstanceName" xml:"InstanceName"`
	CreationTime      string `json:"CreationTime" xml:"CreationTime"`
	Description       string `json:"Description" xml:"Description"`
	IpAddressRange    string `json:"IpAddressRange" xml:"IpAddressRange"`
}