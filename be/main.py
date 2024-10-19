import boto3
import asyncpg
import asyncio

ssm_client = boto3.client('ssm', region_name='ap-southeast-1')  # Điều chỉnh region nếu cần

async def get_ssm_parameter(param_name, with_decryption=True):
    """
    Lấy giá trị của SSM parameter với khả năng giải mã (cho password).
    """
    try:
        response = ssm_client.get_parameter(
            Name=param_name,
            WithDecryption=with_decryption
        )
        return response['Parameter']['Value']
    except Exception as e:
        print(f"Error fetching parameter {param_name}: {e}")
        return None

async def main():

    db_name_param = "/rds/db/khainh_db/dbname"
    db_user_param = "/rds/db/khainh_db/superuser/username"
    db_password_param = "/rds/db/khainh_db/superuser/password"

    db_name = await get_ssm_parameter(db_name_param)
    db_user = await get_ssm_parameter(db_user_param)
    db_password = await get_ssm_parameter(db_password_param)

    print(f"DB Name: {db_name}")
    print(f"DB User: {db_user}")
    print(f"DB Password: {db_password}")

    rds_host = 'khainh-postgres-db.cd4se6sg2tw3.ap-southeast-1.rds.amazonaws.com'
    db_name = 'khainh_db'
    db_port = '5432'  

    print(f"Connecting to RDS instance at {rds_host}:{db_port}")
    try:
        connection = await asyncpg.connect(
            user=db_user,
            password=db_password,
            database=db_name,
            host=rds_host,
            port=db_port
        )

        print("Connection successful!")
        rds_version = await connection.fetchval("SELECT version();")
        print(f"RDS Version: {rds_version}")

    except Exception as e:
        print(f"Error connecting to RDS: {e}")
    finally:
        await connection.close()

if __name__ == "__main__":
    asyncio.run(main())
