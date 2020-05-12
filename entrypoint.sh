#!/bin/sh -l
set -e

SSH_PATH="$HOME/.ssh"

mkdir -p "$SSH_PATH"
touch "$SSH_PATH/known_hosts"

if [ -z "$DEPLOY_KEY" ];
then
  echo ::set-output name=status::'Action did not find the DEPLOY_KEY secret.'
  exit 1
else
  printf '%b\n' "$DEPLOY_KEY" > "$SSH_PATH/deploy_key"
fi

chmod 700 "$SSH_PATH"
chmod 600 "$SSH_PATH/known_hosts" "$SSH_PATH/deploy_key"

eval "$(ssh-agent)"
ssh-add "$SSH_PATH/deploy_key"

#echo "rsync $1 -e 'ssh -i $SSH_PATH/deploy_key -o StrictHostKeyChecking=no $3' $2 $GITHUB_WORKSPACE/$4 $5"
echo "ssh -i $SSH_PATH/deploy_key -o StrictHostKeyChecking=no sh $2"
if ! sh -c "ssh -i $SSH_PATH/deploy_key -o StrictHostKeyChecking=no $5 sh $2"
then
  echo ::set-output name=status::'There was an issue syncing the content.'
  exit 1
else
  echo ::set-output name=status::'Content synced successfully.'
fi
