import hashlib
import json
import time
from datetime import datetime

class BlockchainService:
	def __init__(self):
		self.chain = []
		self.pending_transactions = []
        
		# Create genesis block if chain is empty
		if not self.chain:
			self.create_genesis_block()
    
	def create_genesis_block(self):
		"""Create the first block in the blockchain"""
		genesis_block = {
			'index': 0,
			'timestamp': time.time(),
			'transactions': [],
			'previous_hash': '0',
			'nonce': 0
		}
		genesis_block['hash'] = self.calculate_hash(genesis_block)
		self.chain.append(genesis_block)
    
	def calculate_hash(self, block):
		"""Calculate SHA-256 hash of a block"""
		block_string = json.dumps({
			'index': block['index'],
			'timestamp': block['timestamp'],
			'transactions': block['transactions'],
			'previous_hash': block['previous_hash'],
			'nonce': block['nonce']
		}, sort_keys=True)
        
		return hashlib.sha256(block_string.encode()).hexdigest()
    
	def create_transaction_block(self, farmer_id, buyer_id, crop_id, quantity, price):
		"""Create a new transaction block and add it to the chain"""
		try:
			# Create transaction data
			transaction = {
				'farmer_id': farmer_id,
				'buyer_id': buyer_id,
				'crop_id': crop_id,
				'quantity': quantity,
				'price': price,
				'total_amount': quantity * price,
				'timestamp': time.time(),
				'transaction_id': f"TX{int(time.time())}"
			}
            
			# Get the last block
			previous_block = self.chain[-1] if self.chain else None
			previous_hash = previous_block['hash'] if previous_block else '0'
            
			# Create new block
			new_block = {
				'index': len(self.chain),
				'timestamp': time.time(),
				'transactions': [transaction],
				'previous_hash': previous_hash,
				'nonce': 0
			}
            
			# Calculate hash
			new_block['hash'] = self.calculate_hash(new_block)
            
			# Add block to chain
			self.chain.append(new_block)
            
			return new_block['hash']
            
		except Exception as e:
			print(f"Blockchain error: {str(e)}")
			return None
    
	def verify_transaction(self, transaction_hash):
		"""Verify if a transaction exists in the blockchain"""
		for block in self.chain:
			if block['hash'] == transaction_hash:
				return True, block
		return False, None
    
	def get_transaction_history(self, user_id):
		"""Get all transactions for a specific user"""
		user_transactions = []
        
		for block in self.chain:
			for transaction in block['transactions']:
				if (transaction.get('farmer_id') == user_id or 
					transaction.get('buyer_id') == user_id):
					user_transactions.append({
						'block_hash': block['hash'],
						'block_index': block['index'],
						'transaction': transaction,
						'verified': True
					})
        
		return user_transactions
    
	def validate_chain(self):
		"""Validate the entire blockchain"""
		for i in range(1, len(self.chain)):
			current_block = self.chain[i]
			previous_block = self.chain[i-1]
            
			# Check if current block's hash is valid
			if current_block['hash'] != self.calculate_hash(current_block):
				return False
            
			# Check if current block points to previous block
			if current_block['previous_hash'] != previous_block['hash']:
				return False
        
		return True

# Global blockchain service instance
blockchain_service = BlockchainService()
