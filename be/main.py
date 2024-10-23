from flask import Flask, jsonify
import boto3
import asyncpg
import asyncio
import logging

app = Flask(__name__)
ssm_client = boto3.client('ssm', region_name='ap-southeast-1')

# Set up logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

async def get_ssm_parameter(param_name, with_decryption=True):
    try:
        logging.info(f"Starting to get SSM parameter: {param_name}")
        response = ssm_client.get_parameter(
            Name=param_name,
            WithDecryption=with_decryption
        )
        return response['Parameter']['Value']
    except Exception as e:
        logging.error(f"Error fetching parameter {param_name}: {e}")
        return None

async def fetch_db_info():
    db_name_param = "/rds/db/khainh_db/dbname"
    db_user_param = "/rds/db/khainh_db/superuser/username"
    db_password_param = "/rds/db/khainh_db/superuser/password"
    db_endpoint_param = "/rds/db/khainh_db/superuser/dbendpoint"
    db_port_param = "/rds/db/khainh_db/superuser/dbport"

    db_name = await get_ssm_parameter(db_name_param)
    db_user = await get_ssm_parameter(db_user_param)
    db_password = await get_ssm_parameter(db_password_param)
    db_port = await get_ssm_parameter(db_port_param)
    db_endpoint = await get_ssm_parameter(db_endpoint_param)

    logging.info(f"DB credentials fetched - User: {db_user}, Name: {db_name}")

    connection = None
    try:
        connection = await asyncpg.connect(
            user=db_user,
            password=db_password,
            database=db_name,
            host=db_endpoint,
            port=db_port
        )

        rds_version = await connection.fetchval("SELECT version();")
        logging.info(f"Connected to RDS. Version: {rds_version}")
        return {
            'db_name': db_name,
            'db_user': db_user,
            'db_password': db_password,
            'rds_version': rds_version
        }
    except Exception as e:
        logging.error(f"Error connecting to RDS: {e}")
        return None
    finally:
        if connection:
            await connection.close()

@app.route('/info', methods=['GET'])
async def info():
    db_info = await fetch_db_info()
    if db_info:
        return jsonify(db_info), 200
    else:
        logging.error("Unable to fetch database info.")
        return jsonify({"error": "Unable to fetch database info"}), 500

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
