
# Dépenses App (v0.4)
Ajouts:
- 🖼️ **Aperçu des pièces jointes** pour les approbateurs (images en aperçu; PDF icône).
- 🕒 **Historique détaillé** (timeline horodatée) : chaque action journalisée (création, approbations N1/N2, refus).
- 🔔 **Notifications** (mock) aux employés et approbateurs + notes d’intégration **FCM/APNs**.
- ✉️ **Appro N2**: sélectionner un **destinataire de paiement** (liste préconfigurée) **ou** saisir une **adresse courriel**.

## Intégration notifications (à brancher)
- Android/iOS: **Firebase Cloud Messaging** (FCM). iOS: APNs via FCM. 
- Points d’accroche: `NotificationService.send(...)` est appelé à chaque événement clé.
- Backend: stocker `deviceToken` par utilisateur; endpoint `/notify` (liste d’emails → jetons) pour diffuser.

## Destinataire de paiement (N2)
- UI: liste déroulante (ex. *Comptes payables*, *Finance centrale*) **ou** champ email.
- Backend: POST `/payments/dispatch` avec `{ expenseId, recipientType: 'group'|'email', recipient, payload }`.
