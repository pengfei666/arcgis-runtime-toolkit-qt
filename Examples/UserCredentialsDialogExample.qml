/*******************************************************************************
 * Copyright 2012-2016 Esri
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 ******************************************************************************/

import QtQuick 2.3
import QtQuick.Window 2.0
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2
import Esri.ArcGISRuntime 100.0
import Esri.ArcGISRuntime.Toolkit.Controls 2.0
import Esri.ArcGISRuntime.Toolkit.Dialogs 2.0

Rectangle {
    id: searchBoxExample
    clip: true

    property string errorString
    property bool signedIn: false
    property string portalUrl: "http://www.arcgis.com"
    property Portal portal
    signal signInCompleted
    signal signInErrored(var error)

    UserCredentialsDialog {
        id: userCredentialDialog
        visible: false

        onAccepted: {
            busy = true;
            portal = ArcGISRuntimeEnvironment.createObject("Portal", {url: portalUrl});
            portal.signInStatusChanged.connect(function () {
                if (portal.signInStatus === Enums.TaskStatusCompleted) {
                    signedIn = true;
                    signInCompleted();
                    busy = false;
                    visible = false;
                } else if (portal.signInStatus === Enums.TaskStatusErrored) {
                    visible = false;
                    signInErrored(portal.signInError);
                    errorString = "Error during sign in.\n" + portal.signInError.code + ": " + portal.signInError.message + "\n" + portal.signInError.additionalMessage;
                    busy = false;
                    errorDialog.open();
                }
            });
            userCredential.username = username;
            userCredential.password = password;
            portal.credential = userCredential;
            portal.signIn();
        }

        Credential {
            id: userCredential
        }

        MessageDialog {
            id: errorDialog
            text: errorString
            title: "Sign In Error"
            standardButtons: StandardButton.Ok
            onAccepted: {
                userCredentialDialog.visible = true;
                userCredentialDialog.contentItem.height = Math.min(userCredentialDialog.contentItem.screenHeight, userCredentialDialog.contentItem.scaledHeight)
                userCredentialDialog.contentItem.width = Math.min(userCredentialDialog.contentItem.screenWidth, userCredentialDialog.contentItem.scaledWidth)

                if(Qt.platform.os !== "ios" && Qt.platform.os != "android") {
                    userCredentialDialog.height = Math.min(userCredentialDialog.contentItem.screenHeight, userCredentialDialog.contentItem.scaledHeight)
                    userCredentialDialog.width = Math.min(userCredentialDialog.contentItem.screenWidth, userCredentialDialog.contentItem.scaledWidth)
                }
            }
        }
    }

    Column {
        anchors {
            fill: parent
            margins: 15
        }

        Text {
            width: searchBoxExample.width
            clip: true
            font.pointSize: 14
            wrapMode: Text.WordWrap
            text: signedIn ? "Full name: " + portal.portalUser.fullName : "";
        }

        Text {
            width: searchBoxExample.width
            clip: true
            font.pointSize: 14
            wrapMode: Text.WordWrap
            text: signedIn ? "\nCreated on: " + portal.portalUser.created : "";
        }

        Text {
            width: searchBoxExample.width
            clip: true
            font.pointSize: 14
            wrapMode: Text.WordWrap
            text: signedIn ? "\nModified on: " + portal.portalUser.modified : "";
        }

        Text {
            width: searchBoxExample.width
            clip: true
            font.pointSize: 14
            wrapMode: Text.WordWrap
            text: signedIn ? "\nOrganization Id: " + portal.portalInfo.organizationId : "";
        }

        Text {
            width: searchBoxExample.width
            clip: true
            wrapMode: Text.WrapAnywhere
            font.pointSize: 14
            text: signedIn ? "\nLicense string: " + portal.portalInfo.licenseInfo.json["licenseString"] : "";
        }
    }

    Button {
        id: button
        anchors {
            right: parent.right
            bottom: parent.bottom
            margins: 15
        }
        text: "Sign In"
        onClicked: {
            userCredentialDialog.visible = true;
            userCredentialDialog.contentItem.height = Math.min(userCredentialDialog.contentItem.screenHeight, userCredentialDialog.contentItem.scaledHeight)
            userCredentialDialog.contentItem.width = Math.min(userCredentialDialog.contentItem.screenWidth, userCredentialDialog.contentItem.scaledWidth)

            if(Qt.platform.os !== "ios" && Qt.platform.os != "android") {
                userCredentialDialog.height = Math.min(userCredentialDialog.contentItem.screenHeight, userCredentialDialog.contentItem.scaledHeight)
                userCredentialDialog.width = Math.min(userCredentialDialog.contentItem.screenWidth, userCredentialDialog.contentItem.scaledWidth)
            }
        }
    }

    Component.onCompleted: userCredentialDialog.visible = false;
}
