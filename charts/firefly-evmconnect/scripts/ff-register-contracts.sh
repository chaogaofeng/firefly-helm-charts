#!/bin/bash

# Copyright © 2022 Kaleido, Inc.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://swww.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

until STATUS=$(curl --fail -s ${EVMCONNECT_URL}/status); do
  echo "Waiting for Evmconnect..."
  sleep 5
done

id=$(curl --fail -s -X POST -H "Content-Type:application/json" --data "{\"headers\":{\"type\":\"DeployContract\"},\"to\":\"\",\"from\":\"${FROM_ADDRESS}\",\"definition\":$(cat /var/lib/ethconnect/contracts/Firefly.json | jq -r '.contracts.Firefly.abi'),\"contract\":\"$(cat /var/lib/ethconnect/contracts/Firefly.json | jq -r '.contracts.Firefly.bin')\"}" ${EVMCONNECT_URL} | jq -r .id)
while true
do
  txResponse=$(curl --fail -s ${EVMCONNECT_URL}/transactions/${id})
  status=$(echo -n ${txResponse} | jq -r .status)
  echo $id $status
  if [ "${status}" = "Succeeded" ]; then
    FIREFLY_CONTRACT_ADDRESS=$(echo -n ${txResponse} | jq -r .receipt.extraInfo.contractAddress)
    echo "[${FIREFLY_CONTRACT_ADDRESS}] is already registered for the FireFly contract at $(echo -n ${txResponse} | jq -r .receipt.blockNumber)." 
  break
  fi
  sleep 5
done

id=$(curl --fail -s -X POST -H "Content-Type:application/json" --data "{\"headers\":{\"type\":\"DeployContract\"},\"to\":\"\",\"from\":\"${FROM_ADDRESS}\",\"definition\":$(cat /var/lib/ethconnect/contracts/TokenFactory.json | jq -r '.abi'),\"contract\":\"$(cat /var/lib/ethconnect/contracts/TokenFactory.json | jq -r '.bytecode')\"}" ${EVMCONNECT_URL} | jq -r .id)
echo $deploy
while true
do
  txResponse=$(curl --fail -s ${EVMCONNECT_URL}/transactions/${id})
  status=$(echo -n ${txResponse} | jq -r .status)
  echo $id $status
  if [ "${status}" = "Succeeded" ]; then
    FIREFLY_ERC21_ERC721_CONTRACT_ADDRESS=$(echo -n ${txResponse} | jq -r .receipt.extraInfo.contractAddress)
    echo "[${FIREFLY_ERC21_ERC721_CONTRACT_ADDRESS}] is already registered for the FireFly ERC21_ERC721 contract at $(echo -n ${txResponse} | jq -r .receipt.blockNumber).."
    break
  fi
  sleep 5
done

# id=$(curl --fail -s -X POST -H "Content-Type:application/json" --data "{\"headers\":{\"type\":\"DeployContract\"},\"to\":\"\",\"from\":\"${FROM_ADDRESS}\",\"definition\":$(cat /var/lib/ethconnect/contracts/ERC1155MixedFungible.json | jq -r '.abi'),\"contract\":\"$(cat /var/lib/ethconnect/contracts/ERC1155MixedFungible.json | jq -r '.bytecode')\"}" ${EVMCONNECT_URL} | jq -r .id)
# while true
# do
#   txResponse=$(curl --fail -s ${EVMCONNECT_URL}/transactions/${id})
#   status=$(echo -n ${txResponse} | jq -r .status)
#   echo $id $status
#   if [ "${status}" == "Succeeded" ]; then
#     FIREFLY_ERC1155_CONTRACT_ADDRESS=$(echo -n ${txResponse} | jq -r .receipt.extraInfo.contractAddress)
#     echo "[${FIREFLY_ERC1155_CONTRACT_ADDRESS}] is already registered for the FireFly ERC1155 contract at $(echo -n ${txResponse} | jq -r .receipt.blockNumber).."
#     break
#   fi
# done

